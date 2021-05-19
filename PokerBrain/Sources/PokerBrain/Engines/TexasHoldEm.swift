//
//  TexasHoldEm.swift
//  
//
//  Created by Cody Morley on 5/9/21.
//

import Foundation

struct TexasHoldEm {
    //MARK: - Types -
    enum BettingRound: Int {
        case preflop = 0
        case postflop = 1
        case turn = 2
        case river = 3
    }
    
    
    //MARK: - Properties -
    //objects
    var players: [Player]
    var deck: Deck
    var button: Int = 0
    var pot: Pot
    var communityCards: [Card] = []
    var evaluator = HandEvaluator()
    
    //stakes
    var minimumBet: Double
    var bigBlind: Double
    var smallBlind: Double {
        return minimumBet * 0.5
    }
    var ante: Double?
    
    //tracking gameplay
    var currentBet: Double = 0
    var playersInHand: [Player]
    var bettingRound: Int = 0
    private(set) var lastToAct: Int = 0
    
    
    
    init(startingPlayers: [Player], blinds: Double = 100) {
        guard startingPlayers.count > 1 else { fatalError("Not enough players to start a new game.") }
        guard startingPlayers.count < 11 else { fatalError("Too many players for table.") }
        var unseatedPlayers = startingPlayers
        for i in 0..<unseatedPlayers.count {
            unseatedPlayers[i].seat = i
        }
        let seatedPlayers = unseatedPlayers.sorted(by: {$0.seat < $1.seat})
        
        
        players = seatedPlayers
        playersInHand = seatedPlayers.filter( {$0.isInHand} )
        deck = Deck()
        pot = Pot()
        bigBlind = blinds
        minimumBet = blinds
    }
    
    
    // MARK: - Bookkeeping Functions -
    //TODO: - Hand Begin -
    //pay blinds
    //deal cards
    //set player to act
    
    private mutating func dealStartingHands() {
        var notFinished = true
        while notFinished {
            notFinished = false
            for i in button + 1..<players.count {
                if players[i].isInHand {
                    if players[i].holeCardCount < 2 {
                        if let card = deck.deal() {
                            players[i].dealHoleCard(card)
                        }
                        notFinished = true
                    }
                }
            }
            for i in 0..<button + 1 {
                if players[i].isInHand {
                    if players[i].holeCardCount < 2 {
                        if let card = deck.deal() {
                            players[i].dealHoleCard(card)
                        }
                        notFinished = true
                    }
                }
            }
        }
    }
    
    private mutating func payBlinds() {
        switch button + 1 > players.count - 1 {
        case true:
            players[0].chipsToPot(smallBlind)
            players[1].chipsToPot(bigBlind)
            lastToAct = players[1].seat
        case false:
            switch button + 2 > players.count - 1 {
            case true:
                players[button + 1].chipsToPot(smallBlind)
                players[0].chipsToPot(bigBlind)
                lastToAct = players[0].seat
            case false:
                players[button + 1].chipsToPot(smallBlind)
                players[button + 2].chipsToPot(bigBlind)
                lastToAct = players[button + 2].seat
            }
        }
    }
    
    private func checkRoundIsOver() -> Bool {
        let remaining = players.filter({$0.isInHand})
        if remaining.count < 2 { return true }
        for player in remaining {
            if player.isYetToAct { return false }
        }
        return true
    }
    
    private mutating func findNextToAct() {
        let remaining = players.filter({$0.isInHand && $0.isYetToAct}).sorted(by: {$0.seat < $1.seat})
        guard remaining.count > 1 else { return }
        
        for player in remaining {
            if player.seat > lastToAct {
                if let i = players.firstIndex(of: player) {
                    players[i].isActingPlayer = true
                    return
                }
            }
        }
        
        if let i = players.firstIndex(of: remaining[0]) {
            players[i].isActingPlayer = true
            return
        }
    }
    
    
    // MARK: - HAND EVALUATION FUNCTIONS -
    private mutating func showdown(_ players: [Player]) -> [Player] {
        guard players.count != 1 else {
            return players
        }
        
        var best: HandStrength = .highCard
        for player in players {
            if let playerHand = player.hand?.handStrength, playerHand > best {
                best = playerHand
            }
        }
        
        var bestHands = players.filter( {$0.hand?.handStrength == best} )
        if bestHands.count == 1 { return bestHands }
        
        for firstPlayer in bestHands {
            if bestHands.count == 1 { return bestHands }
            for secondPlayer in bestHands {
                if firstPlayer.id == secondPlayer.id { continue }
                
                if let firstIndex = bestHands.firstIndex(of: firstPlayer),
                   let secondIndex = bestHands.firstIndex(of: secondPlayer),
                   let hand1 = firstPlayer.hand,
                   let hand2 = secondPlayer.hand,
                   let result = evaluator.evaluateHigh(hand1, vs: hand2) {
                    switch result {
                    case true:
                        bestHands.remove(at: secondIndex)
                    case false:
                        bestHands.remove(at: firstIndex)
                    }
                }
            }
        }
        return bestHands
    }
    
    
    
    
}

