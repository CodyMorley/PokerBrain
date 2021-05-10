//
//  Card.swift
//  
//
//  Created by Cody Morley on 5/9/21.
//

import Foundation

struct Card: Equatable {
    let rank: Rank
    let suit: Suit
    
    init(_ cardRank: Rank, _ cardSuit: Suit ) {
        rank = cardRank
        suit = cardSuit
    }
}
