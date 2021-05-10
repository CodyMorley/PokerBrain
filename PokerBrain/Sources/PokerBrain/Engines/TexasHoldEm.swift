//
//  TexasHoldEm.swift
//  
//
//  Created by Cody Morley on 5/9/21.
//

import Foundation

struct TexasHoldEm {
    //objects
    var players: [Player]
    var deck: Deck
    var pot: Double = 0
    var card1: Card? = nil
    var card2: Card? = nil
    var card3: Card? = nil
    var card4: Card? = nil
    var card5: Card? = nil
    
    //stakes
    var minimumBet: Double
    var smallBlind: Double {
        return minimumBet * 0.5
    }
    var ante: Double?
    //tracking gameplay
    var buttonOnPlayer: Int
    var payingSmallBlind: Int { return buttonOnPlayer + 1 }
    var payingBigBlind: Int { return buttonOnPlayer + 2 }
    var actionOnPlayer: Int
    var currentBet: Double = 0
    var playersInHand: [Player]
    var roundTracker: [Double?]
    
    
    
    init(startingPlayers: [Player], blinds: Double = 100, newDeck: Deck = Deck()) {
        guard startingPlayers.count > 1 else { fatalError("Not enough players to start a new game.") }
        guard startingPlayers.count < 11 else { fatalError("Too many players for table.") }
        func setButton() -> Int {
            return Int.random(in: 0..<startingPlayers.count)
        }
        var tracker = [Double?]()
        for _ in startingPlayers {
            tracker.append(nil)
        }
        
        players = startingPlayers
        playersInHand = startingPlayers
        deck = newDeck
        minimumBet = blinds
        buttonOnPlayer = setButton()
        actionOnPlayer = buttonOnPlayer + 3
        roundTracker = tracker
    }
    
    
    mutating func shuffleUpAndDeal() {
        //TODO
        //pay small blind
        //pay big blind
        //deal cards
        //set action on player
    }
    
    mutating func check() {
        nextPlayer()
    }
    
    mutating func call(_ player: inout Player, for amount: Double) {
        if let i = playersInHand.firstIndex(where: {$0.name == player.name}) {
            if amount >= player.stack {
                if roundTracker[i] == nil {
                    roundTracker[i] = player.stack
                    player.stack = 0
                } else {
                    if var bet = roundTracker[i] {
                        bet += player.stack
                        roundTracker[i] = bet
                        player.stack = 0
                    }
                }
            } else {
                if roundTracker[i] == nil {
                    roundTracker[i] = amount
                    player.stack -= amount
                } else {
                    if var bet = roundTracker[i] {
                        bet += amount
                        roundTracker[i] = bet
                        player.stack -= amount
                    }
                }
            }
        }
        nextPlayer()
    }
    
    mutating func bet(_ player: inout Player, of amount: Double) {
        guard amount <= player.stack, amount >= minimumBet else { return }
        
        player.stack -= amount
        minimumBet = amount
        currentBet = amount
        if let i = playersInHand.firstIndex(where: {$0.name == player.name}) {
            roundTracker[i] = amount
        }
        nextPlayer()
    }
    
    mutating func raise(_ player: inout Player, by amount: Double) {
        guard amount <= player.stack, amount >= minimumBet else { return }
        
        player.stack -= amount
        minimumBet += amount
        currentBet += amount
        if let i = playersInHand.firstIndex(where: {$0.name == player.name}) {
            roundTracker[i] = currentBet
        }
        nextPlayer()
    }
    
    mutating func fold(_ player: Player) {
        if let i = playersInHand.firstIndex(where: {$0.name == player.name}) {
            playersInHand.remove(at: i)
            if let hangingBet = roundTracker[i] {
                pot += hangingBet
            }
            roundTracker.remove(at: i)
        }
        nextPlayer()
    }
    
    mutating func settleRound() {
        for i in 0..<roundTracker.count {
            if let roundBet = roundTracker[i] {
                pot += roundBet
            }
            roundTracker[i] = nil
        }
        if playersInHand.count == 1 {
            settleHand()
            return
        }
        actionOnPlayer = playersInHand.index(after: buttonOnPlayer)
    }
    
    mutating func showdown() {
        //TODO
        //compare all reamining hands to find best hand
        //when one hand remains settle hand
    }
    
    mutating func settleHand() {
        //TODO
        //move pot to winning player
        //move button
        //call shuffle up and deal if 2+ players remain
    }
    
    private func evaluate(_ hand1: Hand, vs hand2: Hand) -> Bool? {
        if hand1.handStrength.rawValue > hand2.handStrength.rawValue {
            return true
        } else if hand1.handStrength == hand2.handStrength {
            switch hand1.handStrength {
            case .highCard:
                for i in 4...0 {
                    if hand1.cards.sorted(by: {$0.rank.rawValue < $1.rank.rawValue})[i].rank == hand2.cards.sorted(by: {$0.rank.rawValue < $1.rank.rawValue})[i].rank {
                        continue
                    } else {
                        return hand1.cards.sorted(by: {$0.rank.rawValue < $1.rank.rawValue})[i].rank.rawValue > hand2.cards.sorted(by: {$0.rank.rawValue < $1.rank.rawValue})[i].rank.rawValue
                    }
                }
            case .pair:
                var pair1: Rank? = nil
                var pair2: Rank? = nil
                
                while pair1 == nil || pair2 == nil {
                    for card1 in 0..<hand1.cards.count - 1 {
                        for card2 in card1 + 1..<hand1.cards.count {
                            if hand1.cards[card1].rank == hand1.cards[card2].rank {
                                pair1 = hand1.cards[card1].rank
                            }
                        }
                    }
                    for card1 in 0..<hand2.cards.count - 1 {
                        for card2 in card1 + 1..<hand2.cards.count {
                            if hand2.cards[card1].rank == hand2.cards[card2].rank {
                                pair2 = hand2.cards[card1].rank
                            }
                        }
                    }
                }
                let leftovers1 = hand1.cards.filter({$0.rank != pair1})
                let leftovers2 = hand2.cards.filter({$0.rank != pair2})
                let sortedLeftovers1 = leftovers1.sorted(by: {$0.rank.rawValue < $1.rank.rawValue})
                let sortedLeftovers2 = leftovers2.sorted(by: {$0.rank.rawValue < $1.rank.rawValue})
                
                if let pair1 = pair1, let pair2 = pair2 {
                    if pair1 != pair2 {
                        return pair1.rawValue > pair2.rawValue
                    }
                    else {
                        for i in 2...0 {
                            if sortedLeftovers1[i].rank == sortedLeftovers2[i].rank {
                                continue
                            } else {
                                return sortedLeftovers1[i].rank.rawValue > sortedLeftovers2[i].rank.rawValue
                            }
                        }
                    }
                }
                
            case .twoPair:
                let hand1Sorted = hand1.cards.sorted(by: {$0.rank.rawValue <= $1.rank.rawValue})
                let hand2Sorted = hand2.cards.sorted(by: {$0.rank.rawValue <= $1.rank.rawValue})
                let leftover1: Card = {
                    for i in 0..<hand1Sorted.count - 1 {
                        if hand1Sorted[i].rank.rawValue != hand1Sorted[i - 1].rank.rawValue && hand1Sorted[i].rank.rawValue != hand1Sorted[i + 1].rank.rawValue {
                            return hand1Sorted[i]
                        }
                    }
                }()
                let leftover2: Card = {
                    for i in 0..<hand2Sorted.count - 1 {
                        if hand2Sorted[i].rank.rawValue != hand2Sorted[i - 1].rank.rawValue && hand2Sorted[i].rank.rawValue != hand2Sorted[i + 1].rank.rawValue {
                            return hand2Sorted[i]
                        }
                    }
                }()
                var pairs1: [Card] = hand1Sorted.filter { card in
                    card.rank != leftover1.rank
                }
                pairs1.sort(by: {$0.rank.rawValue <= $1.rank.rawValue})
                var pairs2: [Card] = hand2Sorted.filter { card in
                    card.rank != leftover2.rank
                }
                pairs2.sort(by: {$0.rank.rawValue <= $1.rank.rawValue})
                
                if let high1 = pairs1.last?.rank.rawValue, let high2 = pairs2.last?.rank.rawValue, high1 != high2 {
                    return high1 > high2
                } else if let low1 = pairs1.first?.rank.rawValue, let low2 = pairs2.first?.rank.rawValue, low1 != low2 {
                    return low1 > low2
                } else if leftover1.rank.rawValue != leftover2.rank.rawValue {
                    return leftover1.rank.rawValue > leftover2.rank.rawValue
                }
            case .threeOfAKind:
                let trips1: Rank = {
                    for i in 1...3 {
                        if hand1.cards[i].rank.rawValue == hand1.cards[i - 1].rank.rawValue &&
                            hand1.cards[i].rank.rawValue == hand1.cards[i + 1].rank.rawValue {
                            return hand1.cards[i].rank
                        }
                    }
                }()
                let trips2: Rank = {
                    for i in 1...3 {
                        if hand2.cards[i].rank.rawValue == hand2.cards[i - 1].rank.rawValue &&
                            hand2.cards[i].rank.rawValue == hand2.cards[i + 1].rank.rawValue {
                            return hand2.cards[i].rank
                        }
                    }
                }()
                var leftovers1 = hand1.cards.filter({ card in
                    card.rank.rawValue != trips1.rawValue
                })
                leftovers1.sort(by: {$0.rank.rawValue >= $1.rank.rawValue} )
                var leftovers2 = hand2.cards.filter({ card in
                    card.rank.rawValue != trips2.rawValue
                })
                leftovers2.sort(by: {$0.rank.rawValue >= $1.rank.rawValue} )
                if trips1.rawValue != trips2.rawValue {
                    return trips1.rawValue > trips2.rawValue
                }
                
                if let handOneHigh = leftovers1.last?.rank.rawValue, let handTwoHigh = leftovers2.last?.rank.rawValue, handOneHigh != handTwoHigh {
                    return handOneHigh > handTwoHigh
                }
                
                if let handOneLow = leftovers1.first?.rank.rawValue, let handTwoLow = leftovers2.first?.rank.rawValue, handOneLow != handTwoLow {
                    return handOneLow > handTwoLow
                }
            case .straight:
                if hand1.highCard.rawValue != hand2.highCard.rawValue {
                    return hand1.highCard.rawValue > hand2.highCard.rawValue
                }
            case .flush:
                if hand1.highCard.rawValue != hand2.highCard.rawValue {
                    return hand1.highCard.rawValue > hand2.highCard.rawValue
                }
            case .fullHouse:
                let trips1: Rank = {
                    for i in 1...3 {
                        if hand1.cards[i].rank.rawValue == hand1.cards[i - 1].rank.rawValue && hand1.cards[i].rank.rawValue == hand1.cards[i + 1].rank.rawValue {
                            return hand1.cards[i].rank
                        }
                    }
                }()
                let pair1: Rank
                let trips2: Rank
                let pair2: Rank
                //compare trips
                //compare pairs
            case .fourOfAKind:
                let high1: Rank = {
                    for i in 0..<hand1.cards.count - 1 {
                        if hand1.cards[i].rank.rawValue != hand1.cards[i + 1].rank.rawValue {
                            return hand1.cards[i].rank
                        }
                    }
                }()
                let quads1: Rank = {
                    for i in 0...4 {
                        if hand1.cards[i].rank.rawValue == hand1.cards[i + 1].rank.rawValue {
                            return hand1.cards[i].rank
                        }
                    }
                }()
                let high2: Rank = {
                    for i in 0..<hand2.cards.count - 1 {
                        if hand2.cards[i].rank.rawValue != hand2.cards[i + 1].rank.rawValue {
                            return hand2.cards[i].rank
                        }
                    }
                }()
                let quads2: Rank = {
                    for i in 0...4 {
                        if hand2.cards[i].rank.rawValue == hand2.cards[i + 1].rank.rawValue {
                            return hand2.cards[i].rank
                        }
                    }
                }()
                if quads1.rawValue != quads2.rawValue {
                    return quads1.rawValue > quads2.rawValue
                } else if high1.rawValue != high2.rawValue {
                    return high1.rawValue > high2.rawValue
                }
            case .straightFlush:
                if hand1.highCard.rawValue != hand2.highCard.rawValue {
                    return hand1.highCard.rawValue > hand2.highCard.rawValue
                }
            }
        } else if hand1.handStrength.rawValue < hand2.handStrength.rawValue {
            return false
        }
        return nil
    }
    
    private mutating func nextPlayer() {
        if actionOnPlayer + 1 > playersInHand.count {
            actionOnPlayer = 0
        } else {
            actionOnPlayer += 1
        }
    }
}
