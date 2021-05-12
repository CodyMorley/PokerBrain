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
    var pot: Double = 0
    var communityCards: [Card] = []
    
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
    
    
    
    init(startingPlayers: [Player], blinds: Double = 100, newDeck: Deck = Deck()) {
        guard startingPlayers.count > 1 else { fatalError("Not enough players to start a new game.") }
        guard startingPlayers.count < 11 else { fatalError("Too many players for table.") }
        var unseatedPlayers = startingPlayers
        for i in 0..<unseatedPlayers.count {
            unseatedPlayers[i].seat = i
        }
        let seatedPlayers = unseatedPlayers.sorted(by: {$0.seat < $1.seat})
        
        
        players = seatedPlayers
        playersInHand = seatedPlayers.filter( {$0.isInHand} )
        deck = newDeck
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
        case false:
            switch button + 2 > players.count - 1 {
            case true:
                players[button + 1].chipsToPot(smallBlind)
                players[0].chipsToPot(bigBlind)
            case false:
                players[button + 1].chipsToPot(smallBlind)
                players[button + 2].chipsToPot(bigBlind)
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
        let currentRound = BettingRound(rawValue: bettingRound)
        
        switch currentRound {
        case .preflop:
            if button == remaining.last?.seat {
                if players[button + 1]
                let nextID = remaining.first?.id
                let nextIndex = players.first(where: {player in
                    player.id == nextID
                })
                players[nextIndex].isActingPlayer == true
                return
            } else {
                for i in button + 3..<remaining.count {
                    
                }
            }
        default:
            <#code#>
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
                   let result = evaluate(hand1, vs: hand2) {
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
    
    
    
    private func evaluate(_ hand1: Hand, vs hand2: Hand) -> Bool? {
        if hand1.handStrength.rawValue > hand2.handStrength.rawValue {
            return true
        } else if hand1.handStrength == hand2.handStrength {
            switch hand1.handStrength {
            case .highCard:
                if let result = bothTwoPair(hand1, vs: hand2) {
                    return result
                }
            case .pair:
                if let result = bothPair(hand1, vs: hand2) {
                    return result
                }
            case .twoPair:
                if let result = bothTwoPair(hand1, vs: hand2) {
                    return result
                }
            case .threeOfAKind:
                if let result = bothTrips(hand1, vs: hand2) {
                    return result
                }
            case .straight:
                if let result = bothStraight(hand1, vs: hand2) {
                    return result
                }
            case .flush:
                if let result = bothFlush(hand1, vs: hand2) {
                    return result
                }
            case .fullHouse:
                if let result = bothFlush(hand1, vs: hand2) {
                    return result
                }
            case .fourOfAKind:
                if let result = bothQuads(hand1, vs: hand2) {
                    return result
                }
            case .straightFlush:
                if let result = bothStraightFlush(hand1, vs: hand2) {
                    return result
                }
            }
        } else if hand1.handStrength.rawValue < hand2.handStrength.rawValue {
            return false
        }
        return nil
    }
    
    
    private func bothHighCard(_ hand1: Hand, vs hand2: Hand) -> Bool? {
        guard hand1.handStrength == .highCard, hand2.handStrength == .highCard else { fatalError("Tried to pass dissimilar hands for close comparison: High Card. Hand1: \(String(describing: hand1.handStrength)) Hand2: \(String(describing: hand2.handStrength))") }
        
        for i in 4...0 {
            if hand1.cards.sorted(by: {$0.rank.rawValue < $1.rank.rawValue})[i].rank == hand2.cards.sorted(by: {$0.rank.rawValue < $1.rank.rawValue})[i].rank {
                continue
            } else {
                return hand1.cards.sorted(by: {$0.rank.rawValue < $1.rank.rawValue})[i].rank.rawValue > hand2.cards.sorted(by: {$0.rank.rawValue < $1.rank.rawValue})[i].rank.rawValue
            }
        }
        
        return nil
    }
    
    private func bothPair(_ hand1: Hand, vs hand2: Hand) -> Bool? {
        guard hand1.handStrength == .pair, hand2.handStrength == .pair else { fatalError("Tried to pass dissimilar hands for close comparison: Pair. Hand1: \(String(describing: hand1.handStrength)) Hand2: \(String(describing: hand2.handStrength))") }
        let sorted1 = hand1.cards.sorted(by: {$0.rank.rawValue <= $1.rank.rawValue})
        let sorted2 = hand2.cards.sorted(by: {$0.rank.rawValue <= $1.rank.rawValue})
        var pairVal1 = 0
        var pairVal2 = 0
        var leftovers1: [Card] = []
        var leftovers2: [Card] = []
        
        for i in 0..<sorted1.count {
            var tempArr: [Card] = sorted1
            if sorted1[i] == sorted1[i + 1] {
                pairVal1 = sorted1[i].rank.rawValue
                tempArr.remove(at: i + 1)
                tempArr.remove(at: i)
                leftovers1 = tempArr
                break
            }
        }
        
        for i in 0..<sorted2.count {
            var tempArr: [Card] = sorted2
            if sorted2[i] == sorted2[i + 1] {
                pairVal2 = sorted2[i].rank.rawValue
                tempArr.remove(at: i + 1)
                tempArr.remove(at: i)
                leftovers2 = tempArr
                break
            }
        }
        leftovers1.sort(by: {$0.rank.rawValue >= $1.rank.rawValue})
        leftovers1.sort(by: {$0.rank.rawValue >= $1.rank.rawValue})
        
        switch pairVal1 == pairVal2 {
        case true:
            break
        default:
            return pairVal1 > pairVal2
        }
        
        for i in 0..<leftovers1.count {
            if leftovers1[i].rank.rawValue != leftovers2[i].rank.rawValue {
                return leftovers1[i].rank.rawValue > leftovers2[i].rank.rawValue
            }
        }
        
        return nil
    }
    
    private func bothTwoPair(_ hand1: Hand, vs hand2: Hand) -> Bool? {
        guard hand1.handStrength == .twoPair, hand2.handStrength == .twoPair else { fatalError("Tried to pass dissimilar hands for close comparison: Two Pair. Hand1: \(String(describing: hand1.handStrength)) Hand2: \(String(describing: hand2.handStrength))") }
        
        let sorted1 = hand1.cards.sorted(by: {$0.rank.rawValue <= $1.rank.rawValue})
        let sorted2 = hand2.cards.sorted(by: {$0.rank.rawValue <= $1.rank.rawValue})
        
        var pairs1 = sorted1
        var highcard1Rank = 0
        for i in 0..<pairs1.count {
            var tempArr = pairs1
            tempArr.remove(at: i)
            if tempArr.contains(pairs1[i]) {
                continue
            } else {
                highcard1Rank = pairs1[i].rank.rawValue
                pairs1 = tempArr
                break
            }
        }
        var pairs2 = sorted2
        var highcard2Rank = 0
        for i in 0..<pairs2.count {
            var tempArr = pairs2
            tempArr.remove(at: i)
            if tempArr.contains(pairs2[i]) {
                continue
            } else {
                highcard2Rank = pairs2[i].rank.rawValue
                pairs2 = tempArr
                break
            }
        }
        
        switch pairs1[3].rank.rawValue == pairs2[3].rank.rawValue {
        case true:
            break
        case false:
            return pairs1[3].rank.rawValue > pairs2[3].rank.rawValue
        }
        
        switch pairs1[0].rank.rawValue == pairs2[0].rank.rawValue {
        case true:
            break
        case false:
            return pairs1[0].rank.rawValue > pairs2[0].rank.rawValue
        }
        
        switch highcard1Rank == highcard2Rank {
        case true:
            break
        case false:
            return highcard1Rank > highcard2Rank
        }
        return nil
    }
    
    private func bothTrips(_ hand1: Hand, vs hand2: Hand) -> Bool? {
        guard hand1.handStrength == .threeOfAKind, hand2.handStrength == .threeOfAKind else { fatalError("Tried to pass dissimilar hands for close comparison: Three of a Kind. Hand1: \(String(describing: hand1.handStrength)) Hand2: \(String(describing: hand2.handStrength))") }
        
        let sorted1 = hand1.cards.sorted(by: {$0.rank.rawValue <= $1.rank.rawValue})
        let sorted2 = hand2.cards.sorted(by: {$0.rank.rawValue <= $1.rank.rawValue})
        var trips1: Rank = .two
        var trips2: Rank = .two
        var leftovers1: [Card] = []
        var leftovers2: [Card] = []
        for i in 1...3 {
            if sorted1[i].rank.rawValue == sorted1[i - 1].rank.rawValue && sorted1[i].rank.rawValue == sorted1[i + 1].rank.rawValue {
                trips1 = sorted1[i].rank
                for j in 0..<sorted1.count {
                    if sorted1[j].rank != sorted1[i].rank {
                        leftovers1.append(sorted1[j])
                    }
                }
                break
            }
        }
        for i in 1...3 {
            if sorted2[i].rank.rawValue == sorted2[i - 1].rank.rawValue &&
                sorted2[i].rank.rawValue == sorted2[i + 1].rank.rawValue {
                trips2 = sorted2[i].rank
                for j in 0..<sorted2.count {
                    if sorted2[j].rank != sorted2[i].rank {
                        leftovers2.append(sorted2[j])
                    }
                }
                break
            }
        }
        
        if trips1.rawValue != trips2.rawValue {
            return trips1.rawValue > trips2.rawValue
        }
        
        leftovers1.sort(by: {$0.rank.rawValue >= $1.rank.rawValue})
        leftovers2.sort(by: {$0.rank.rawValue >= $1.rank.rawValue})
        
        for i in 0..<leftovers1.count {
            if leftovers1[i].rank.rawValue != leftovers2[i].rank.rawValue {
                return leftovers1[i].rank.rawValue > leftovers2[i].rank.rawValue
            }
        }
        return nil
    }
    
    private func bothStraight(_ hand1: Hand, vs hand2: Hand) -> Bool? {
        guard hand1.handStrength == .straight, hand2.handStrength == .straight else { fatalError("Tried to pass dissimilar hands for close comparison: Straight. Hand1: \(String(describing: hand1.handStrength)) Hand2: \(String(describing: hand2.handStrength))") }
        
        if hand1.highCard.rawValue != hand2.highCard.rawValue {
            return hand1.highCard.rawValue > hand2.highCard.rawValue
        }
        
        return nil
    }
    
    private func bothFlush(_ hand1: Hand, vs hand2: Hand) -> Bool? {
        guard hand1.handStrength == .flush, hand2.handStrength == .flush else { fatalError("Tried to pass dissimilar hands for close comparison: Flush. Hand1: \(String(describing: hand1.handStrength)) Hand2: \(String(describing: hand2.handStrength))") }
        
        if hand1.highCard.rawValue != hand2.highCard.rawValue {
            return hand1.highCard.rawValue > hand2.highCard.rawValue
        }
        
        return nil
    }
    
    private func bothFullHouse(_ hand1: Hand, vs hand2: Hand) -> Bool? {
        guard hand1.handStrength == .fullHouse, hand2.handStrength == .fullHouse else { fatalError("Tried to pass dissimilar hands for close comparison: Full House. Hand1: \(String(describing: hand1.handStrength)) Hand2: \(String(describing: hand2.handStrength))") }
        let sorted1 = hand1.cards.sorted(by: {$0.rank.rawValue <= $1.rank.rawValue})
        let sorted2 = hand2.cards.sorted(by: {$0.rank.rawValue <= $1.rank.rawValue})
        var trips1: Rank = .two
        var pair1: Rank = .two
        var trips2: Rank = .two
        var pair2: Rank = .two
        
        for i in 1...3 {
            if sorted1[i].rank.rawValue == sorted1[i - 1].rank.rawValue && sorted1[i].rank.rawValue == sorted1[i + 1].rank.rawValue {
                trips1 = sorted1[i].rank
                var tempArr = sorted1
                for _ in 1...3 {
                    tempArr.remove(at: i - 1)
                }
                pair1 = tempArr[0].rank
            }
        }
        
        for i in 1...3 {
            if sorted2[i].rank.rawValue == sorted2[i - 1].rank.rawValue && sorted2[i].rank.rawValue == sorted2[i + 1].rank.rawValue {
                trips2 = sorted2[i].rank
                var tempArr = sorted2
                for _ in 1...3 {
                    tempArr.remove(at: i - 1)
                }
                pair2 = tempArr[0].rank
            }
        }
        
        
        if trips1.rawValue != trips2.rawValue {
            return trips1.rawValue > trips2.rawValue
        }
        
        if pair1.rawValue != pair2.rawValue {
            return pair1.rawValue > pair2.rawValue
        }
        
        return nil
    }
    
    
    private func bothQuads(_ hand1: Hand, vs hand2: Hand) -> Bool? {
        guard hand1.handStrength == .fourOfAKind, hand2.handStrength == .fourOfAKind else { fatalError("Tried to pass dissimilar hands for close comparison: Four of a Kind. Hand1: \(String(describing: hand1.handStrength)) Hand2: \(String(describing: hand2.handStrength))") }
        let sorted1 = hand1.cards.sorted(by: {$0.rank.rawValue <= $1.rank.rawValue})
        let sorted2 = hand2.cards.sorted(by: {$0.rank.rawValue <= $1.rank.rawValue})
        
        var quads1: Rank = .two
        var quads2: Rank = .two
        var hi1: Rank = .two
        var hi2: Rank = .two
        
        switch sorted1[0].rank.rawValue == sorted1[1].rank.rawValue {
        case true:
            quads1 = sorted1[0].rank
            hi1 = sorted1[4].rank
        case false:
            quads1 = sorted1[4].rank
            hi1 = sorted1[0].rank
        }
        
        switch sorted2[0].rank.rawValue == sorted2[1].rank.rawValue {
        case true:
            quads2 = sorted2[0].rank
            hi2 = sorted2[4].rank
        case false:
            quads2 = sorted2[4].rank
            hi2 = sorted2[0].rank
        }
        
        if quads1.rawValue != quads2.rawValue {
            return quads1.rawValue > quads2.rawValue
        }
        
        if hi1.rawValue != hi2.rawValue {
            return hi1.rawValue > hi2.rawValue
        }
        
        return nil
    }
    
    private func bothStraightFlush(_ hand1: Hand, vs hand2: Hand) -> Bool? {
        guard hand1.handStrength == .straightFlush, hand2.handStrength == .straightFlush else { fatalError("Tried to pass dissimilar hands for close comparison: Straight Flush. Hand1: \(String(describing: hand1.handStrength)) Hand2: \(String(describing: hand2.handStrength))") }
        
        if hand1.highCard.rawValue != hand2.highCard.rawValue {
            return hand1.highCard.rawValue > hand2.highCard.rawValue
        }
        
        return nil
    }
}

