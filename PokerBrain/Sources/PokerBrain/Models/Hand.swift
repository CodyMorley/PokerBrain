//
//  Hand.swift
//  
//
//  Created by Cody Morley on 5/9/21.
//

import Foundation

struct Hand {
    private let card1: Card
    private let card2: Card
    private let card3: Card
    private let card4: Card
    private let card5: Card
    public let cards: [Card]
    
    private var sortedBySuit: [Card] {
        return cards.sorted {
            $0.suit.rawValue < $1.suit.rawValue
        }
    }
    private var sortedByRank: [Card] {
        return cards.sorted {
            $0.rank.rawValue < $1.rank.rawValue
        }
    }
    
    public var handStrength: HandStrength {
        //TODO:
        return getHandStrength()
    }
    
    public var highCard: Rank {
        if handStrength == .straight {
            if sortedByRank[4].rank == .ace {
                if sortedByRank[3].rank == .five {
                    return .five
                } else {
                    return sortedByRank[4].rank
                }
            }
        }
        return sortedByRank[4].rank
    }
    
    
    init(_ cardOne: Card, _ cardTwo: Card,
         _ cardThree: Card, _ cardFour: Card,
         _ cardFive: Card) {
        
        let cardsArr = [cardOne, cardTwo, cardThree, cardFour, cardFive]
        for i in 0...3 {
            for j in i+1..<cardsArr.count - 1 {
                if cardsArr[i].rank == cardsArr[j].rank && cardsArr[i].suit == cardsArr[j].suit {
                    fatalError("Cannot use two identical cards to form a legal hand.")
                }
            }
        }
        
        card1 = cardOne
        card2 = cardTwo
        card3 = cardThree
        card4 = cardFour
        card5 = cardFive
        cards = cardsArr
    }
    
    private func checkPair() -> Bool {
        for i in 0..<cards.count - 1 {
            if sortedByRank[i].rank == sortedByRank[i + 1].rank {
                return true
            }
        }
        return false
    }
    
    private func checkTwoPair() -> Bool {
        if (sortedByRank[0].rank == sortedByRank[1].rank && sortedByRank[2].rank == sortedByRank[3].rank) ||
            (sortedByRank[0].rank == sortedByRank[1].rank && sortedByRank[3].rank == sortedByRank[4].rank) ||
            (sortedByRank[1].rank == sortedByRank[2].rank && sortedByRank[3].rank == sortedByRank[4].rank){
            return true
        }
        return false
    }
    
    private func checkTrips() -> Bool {
        if sortedByRank[0].rank == sortedByRank[2].rank ||
        sortedByRank[1].rank == sortedByRank[3].rank ||
        sortedByRank[2].rank == sortedByRank[4].rank {
            return true
        }
        return false
    }
    
    private func checkStraight() -> Bool {
        guard !checkPair() else { return false }
        if sortedByRank[4].rank.rawValue - sortedByRank[0].rank.rawValue == 4 {
            return true
        } else if sortedByRank[4].rank == .ace {
            if sortedByRank[3].rank == .five {
                if sortedByRank[3].rank.rawValue - sortedByRank[0].rank.rawValue == 3 {
                    return true
                }
            }
        }
        return false
    }
    
    private func checkFlush() -> Bool {
        guard !checkPair() else { return false }
        if sortedBySuit[0].suit == sortedBySuit[4].suit {
            return true
        }
        return false
    }
    
    private func checkFullHouse() -> Bool {
        switch sortedByRank[0].rank == sortedByRank[1].rank {
        case true:
            return sortedByRank[2].rank == sortedBySuit[4].rank
        case false:
            break
        }
        switch sortedByRank[0].rank == sortedByRank[2].rank {
        case true:
            return sortedByRank[3].rank == sortedByRank[4].rank
        case false:
            break
        }
        return false
    }
    
    private func checkQuads() -> Bool {
        if sortedByRank[0].rank == sortedByRank[3].rank ||
            sortedByRank[1].rank == sortedByRank[4].rank {
            return true
        }
        return false
    }
    
    private func checkStraightFlush() -> Bool {
        return checkStraight() && checkFlush()
    }
    
    private func getHandStrength() -> HandStrength {
        if checkPair() {
            if checkTrips() {
                if checkFullHouse() {
                    return .fullHouse
                }
                if checkQuads() {
                    return .fourOfAKind
                }
                return .threeOfAKind
            }
            if checkTwoPair() {
                return .twoPair
            }
            if checkFullHouse() {
                return .fullHouse
            }
            return .pair
        }
        
        if checkStraight() {
            if checkStraightFlush() {
                return .straightFlush
            }
            return .straight
        }
        
        if checkFlush() {
            if checkStraightFlush() {
                return .straightFlush
            }
            return .flush
        }
        return .highCard
    }
}
