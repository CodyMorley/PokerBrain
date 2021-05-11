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
    
    func formatted() -> String {
        var formattedCard = ""
        switch rank {
        case .ace:
            formattedCard.append("Ace of ")
        case .two:
            formattedCard.append("Two of ")
        case .three:
            formattedCard.append("Three of ")
        case .four:
            formattedCard.append("Four of ")
        case .five:
            formattedCard.append("Five of ")
        case .six:
            formattedCard.append("Six of ")
        case .seven:
            formattedCard.append("Seven of ")
        case .eight:
            formattedCard.append("Eight of ")
        case .nine:
            formattedCard.append("Nine of ")
        case .ten:
            formattedCard.append("Ten of ")
        case .jack:
            formattedCard.append("Jack of ")
        case .queen:
            formattedCard.append("Queen of ")
        case .king:
            formattedCard.append("King of ")
        }
        
        switch suit {
        case .hearts:
            formattedCard.append("Hearts")
        case .diamonds:
            formattedCard.append("Diamonds")
        case .spades:
            formattedCard.append("Spades")
        case .clubs:
            formattedCard.append("Clubs")
        }
        
        return formattedCard
    }
    
}
