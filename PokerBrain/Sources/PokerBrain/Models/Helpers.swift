//
//  Helpers.swift
//  
//
//  Created by Cody Morley on 5/9/21.
//

import Foundation

enum Suit: Int, CaseIterable, Equatable {
    case hearts = 1
    case diamonds = 2
    case clubs = 3
    case spades = 4
    
    static func == (_ lhs: Suit, _ rhs: Suit) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

enum Rank: Int, CaseIterable, Comparable, Equatable {
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case seven = 7
    case eight = 8
    case nine = 9
    case ten = 10
    case jack = 11
    case queen = 12
    case king = 13
    case ace = 14
    
    static func < (_ lhs: Rank, _ rhs: Rank) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    static func > (_ lhs: Rank, _ rhs: Rank) -> Bool {
        return lhs.rawValue > rhs.rawValue
    }
    
    static func == (_ lhs: Rank, _ rhs: Rank) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

enum HandStrength: Int, Comparable, Equatable {
    case highCard = 0
    case pair = 1
    case twoPair = 2
    case threeOfAKind = 3
    case straight = 4
    case flush = 5
    case fullHouse = 6
    case fourOfAKind = 7
    case straightFlush = 8
    
    static func < (_ lhs: HandStrength, _ rhs: HandStrength) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    static func > (_ lhs: HandStrength, _ rhs: HandStrength) -> Bool {
        return lhs.rawValue > rhs.rawValue
    }
    
    static func == (_ lhs: HandStrength, _ rhs: HandStrength) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

enum PlayerAction {
    case check
    case call(_ amount: Double)
    case raise(_ amount: Double)
    case fold
}
