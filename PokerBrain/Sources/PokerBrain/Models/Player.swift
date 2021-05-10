//
//  Player.swift
//  
//
//  Created by Cody Morley on 5/9/21.
//

import Foundation

struct Player {
    var name: String
    var stack: Double
    var hand: Hand? {
        if let cards = cards {
            if cards.count < 5 {
                return nil
            } else {
                return bestHand(cards)
            }
        }
        return nil
    }
    var cards: [Card] = []
    
    init(playerName: String, startingStack: Double = 10000) {
        name = playerName
        stack = startingStack
    }
    
    private func bestHand(_ cards: [Card]) -> Hand {
        switch cards.count {
        case 7:
            var hand: Hand?
            for i in 0..<cards.count {
                for j in 0..<cards.count {
                    if i == j { continue }
                    var tryHand = cards
                    tryHand.remove(at: i)
                    tryHand.remove(at: j)
                    let newHand = Hand(tryHand[0], tryHand[1], tryHand[2], tryHand[3], tryHand[4])
                    if hand == nil {
                        hand = newHand
                        continue
                    }
                    if var hand = hand {
                        if newHand.handStrength.rawValue > hand.handStrength.rawValue || (newHand.handStrength.rawValue == hand.handStrength.rawValue && newHand.highCard.rawValue > hand.highCard.rawValue) {
                            hand = newHand
                        }
                    }
                }
            }
            return hand!
        case 6:
            var hand: Hand?
            for i in 0..<cards.count {
                var tryHand = cards
                tryHand.remove(at: i)
                let newHand = Hand(tryHand[0], tryHand[1], tryHand[2], tryHand[3], tryHand[4])
                if hand == nil {
                    hand = newHand
                    continue
                }
                if var hand = hand {
                    if newHand.handStrength.rawValue > hand.handStrength.rawValue || (newHand.handStrength.rawValue == hand.handStrength.rawValue && newHand.highCard.rawValue > hand.highCard.rawValue) {
                        hand = newHand
                    }
                }
            }
            return hand!
        case 5:
            return Hand(cards[0], cards[1], cards[2], cards[3], cards[4])
        default:
            fatalError("Too many or too few cards to make hand.")
        }
    }
}
