//
//  Deck.swift
//  
//
//  Created by Cody Morley on 5/9/21.
//

import Foundation

struct Deck {
    private var fullDeck: [Card]
    private (set)var cards: [Card]
    
    init() {
        var newDeck = [Card]()
        for s in Suit.allCases {
            for r in Rank.allCases {
                newDeck.append(Card(r, s))
            }
        }
        fullDeck = newDeck
        cards = newDeck
    }
    
    public mutating func shuffle() {
        var shuffledCards = fullDeck
        for _ in 1...512 {
            shuffledCards.swapAt(Int.random(in: 0..<cards.count), Int.random(in: 0..<cards.count))
        }
        cards = shuffledCards
    }
    
    public mutating func deal() -> Card? {
        return cards.popLast()
    }
}
