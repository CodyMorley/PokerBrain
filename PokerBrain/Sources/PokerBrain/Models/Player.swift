//
//  Player.swift
//  
//
//  Created by Cody Morley on 5/9/21.
//

import Foundation

struct Player {
    //MARK: - Types -
    enum NotificationKeys: String {
        case playerDidCheck = "playerDidCheck"
        case playerDidCall = "playerDidCall"
        case playerDidRaise = "playerDidRaise"
        case playerDidFold = "playerDidFold"
    }
    //MARK: - Properties -
    // Identifier properties
    public var name: String
    public var seat: Int
    public var id: UUID
    
    // Card/Hand properties
    var holeCardCount: Int { return holeCards.count }
    private var holeCards: [Card] = []
    private(set) var communityCards: [Card] = []
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
    private(set) var isSittingOut = false
    private(set) var isYetToAct: Bool = true
    private(set) var isInHand: Bool = true
    private(set) var isAllIn: Bool = false
    private(set) var betThisRound: Double = 0
    private(set) var chipsInPot: Double = 0
    
    
    //MARK: - Initializer -
    init(playerName: String, playerID: UUID = UUID(), startingStack: Double = 10000, atSeat: Int) {
        name = playerName
        stack = startingStack
        seat = atSeat
        id = playerID
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
    
    private func playerDidTakeAction(_ action: PlayerAction) {
        // TODO use publisher to describe action to subscriber (table)
        var userInfo: [UUID : PlayerAction] = [:]
        switch action {
        case .check:
            userInfo[id] = .check
            NotificationCenter.default.post(name: .playerDidCheck, object: nil, userInfo: userInfo)
        case let .call(amount):
            userInfo[id] = .call(amount)
            NotificationCenter.default.post(name: .playerDidCall, object: nil, userInfo: userInfo)
        case let .raise(amount):
            userInfo[id] = .raise(amount)
            NotificationCenter.default.post(name: .playerDidRaise, object: nil, userInfo: userInfo)
        case .fold:
            userInfo[id] = .fold
            NotificationCenter.default.post(name: .playerDidCheck, object: nil, userInfo: userInfo)
        }
    }
    
    public mutating func actionWasSuccessfull() {
        isActingPlayer = false
        isYetToAct = false
    }
    
    private mutating func dropFromHand() {
        chipsInPot += betThisRound
        betThisRound = 0
        isInHand = false
    }
    
    private mutating func settleRound() {
        chipsInPot += betThisRound
        betThisRound = 0
    }
    
    //MARK: - Public Methods -
    public mutating func newHand() {
        chipsInPot = 0
        betThisRound = 0
        holeCards = []
        communityCards = []
        
        if chipCount > 0 {
            isInHand = true
            isYetToAct = true
        }
    }
    
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
    
    public mutating func dealHoleCard(_ card: Card) {
        holeCards.append(card)
        if holeCards.count == 2 {
            NSLog("Starting hand: \(holeCards[0].formatted()) \(holeCards[1].formatted())")
        }
    }
    
    public mutating func dealCommunityCard(_ card: Card) {
        communityCards.append(card)
        if cards.count > 5, let hand = hand {
            var currentBestHandString = ""
            let currentHandStrength = String(describing: hand.handStrength)
            for card in hand.cards {
                currentBestHandString.append(card.formatted() + " ")
            }
            NSLog("Current best hand for \(name): \n\(currentBestHandString) \n\(currentHandStrength)")
        }
    }
    
    
    //MARK: - Player Actions -
    public func check() {
        guard isActingPlayer else { return }
        playerDidTakeAction(.check)
    }
    
    public func call(_ amount: Double) {
        guard isActingPlayer else { return }
        playerDidTakeAction(.call(amount))
    }
    
    public func raise(_ amount: Double) {
        guard isActingPlayer else { return }
        playerDidTakeAction(.raise(amount))
    }
    
    public func fold(_ amount: Double) {
        guard isActingPlayer else { return }
        playerDidTakeAction(.fold)
    }
    
    public mutating func sitOut() {
        isSittingOut = true
    }
    
    public mutating func sitIn() {
        isSittingOut = false
    }
}

extension Player: Equatable {
    static func == (_ lhs: Player, _ rhs: Player) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Notification.Name {
    static let playerDidCheck: Notification.Name = Notification.Name(Player.NotificationKeys.playerDidCheck.rawValue)
    static let playerDidCall: Notification.Name = Notification.Name(Player.NotificationKeys.playerDidCall.rawValue)
    static let playerDidRaise: Notification.Name = Notification.Name(Player.NotificationKeys.playerDidRaise.rawValue)
    static let playerDidFold: Notification.Name = Notification.Name(Player.NotificationKeys.playerDidFold.rawValue)
}

