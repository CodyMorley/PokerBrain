//
//  Player.swift
//  
//
//  Created by Cody Morley on 5/9/21.
//

import Foundation

struct Player {
    //MARK: - Properties -
    // Identifier properties
    public var name: String
    public var seat: Int
    
    // Card/Hand properties
    var holeCards: [Card] = []
    var communityCards: [Card] = []
    private var cards: [Card] {
        return holeCards + communityCards
    }
    var hand: Hand? {
        if cards.count < 5 {
            return nil
        } else {
            return bestHand(cards)
        }
    }
    // Bookkeeping properties
    var chipCount: Double { return stack }
    private var stack: Double
    var isActingPlayer: Bool = false
    private(set)var isSittingOut = false
    private(set)var isYetToAct: Bool = true
    private(set)var isInHand: Bool = true
    private(set)var isAllIn: Bool = false
    private(set)var betThisRound: Double = 0
    private(set)var chipsInPot: Double = 0
    
    
    //MARK: - Initializer -
    init(playerName: String, startingStack: Double = 10000, atSeat: Int) {
        name = playerName
        stack = startingStack
        seat = atSeat
    }
    
    //MARK: - Private Functions -
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
    
    private mutating func newHand() {
        chipsInPot = 0
        betThisRound = 0
        holeCards = []
        communityCards = []
        
        if chipCount > 0 {
            isInHand = true
            isYetToAct = true
        }
    }
    
    private func playerDidTakeAction(_ action: PlayerAction) {
        // TODO use publisher to describe action to subscriber (table)
    }
    
    private mutating func dropFromHand() {
        chipsInPot += betThisRound
        betThisRound = 0
        isYetToAct = false
        isInHand = false
        isActingPlayer = false
    }
    
    private mutating func settleRound() {
        chipsInPot += betThisRound
        betThisRound = 0
    }
    
    //MARK: - Public Methods -
    
    public mutating func playerWin(_ amount: Double) {
        stack += amount
    }
    
    public mutating func chipsToPot(_ amount: Double) {
        if amount >= stack {
            betThisRound += stack
            stack = 0
            isAllIn = true
        } else {
            betThisRound += amount
            stack -= amount
        }
    }
    
    
    //MARK: - Player Actions -
    public func check() {
        // TODO
        //guard player is active player else return
        //set yet to act to false
        //send player action (will set active player to false)
    }
    
    public func call(_ amount: Double) {
        // TODO
        //guard player is active player else return
        //set yet to act to false
        //send player action (will call back to chips to pot
    }
    
    public func raise(_ amount: Double) {
        // TODO
        //guard player is active player else return
        //set yet to act to false
        //call chips to pot from player
        //send player action (will call back to chips to pot)
    }
    
    public func fold(_ amount: Double) {
        // TODO
        //guard player is active player else return
        //set yet to act to false
        //send player action (will call back to drop player)
    }
    
    public mutating func sitOut() {
        isSittingOut = true
    }
    
    public mutating func sitIn() {
        isSittingOut = false
    }
    
}
