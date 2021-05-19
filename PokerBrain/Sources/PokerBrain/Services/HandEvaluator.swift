//
//  HandEvaluator.swift
//  
//
//  Created by Cody Morley on 5/18/21.
//

import Foundation

struct HandEvaluator {
    
    //MARK: Evaluator function
    /// Returns higher of two hands or nil for tie.
    func evaluateHigh(_ hand1: Hand, vs hand2: Hand) -> Bool? {
        if hand1.handStrength > hand2.handStrength {
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
        } else if hand1.handStrength < hand2.handStrength {
            return false
        }
        return nil
    }
    
    
    private func bothHighCard(_ hand1: Hand, vs hand2: Hand) -> Bool? {
        guard hand1.handStrength == .highCard, hand2.handStrength == .highCard else { fatalError("Tried to pass dissimilar hands for close comparison: High Card. Hand1: \(String(describing: hand1.handStrength)) Hand2: \(String(describing: hand2.handStrength))") }
        
        for i in 4...0 {
            if hand1.cards.sorted(by: {$0.rank < $1.rank})[i].rank == hand2.cards.sorted(by: {$0.rank < $1.rank})[i].rank {
                continue
            } else {
                return hand1.cards.sorted(by: {$0.rank < $1.rank})[i].rank > hand2.cards.sorted(by: {$0.rank < $1.rank})[i].rank
            }
        }
        
        return nil
    }
    
    private func bothPair(_ hand1: Hand, vs hand2: Hand) -> Bool? {
        guard hand1.handStrength == .pair, hand2.handStrength == .pair else { fatalError("Tried to pass dissimilar hands for close comparison: Pair. Hand1: \(String(describing: hand1.handStrength)) Hand2: \(String(describing: hand2.handStrength))") }
        let sorted1 = hand1.cards.sorted(by: {$0.rank <= $1.rank})
        let sorted2 = hand2.cards.sorted(by: {$0.rank <= $1.rank})
        var pairVal1: Rank = .two
        var pairVal2: Rank = .two
        var leftovers1: [Card] = []
        var leftovers2: [Card] = []
        
        for i in 0..<sorted1.count {
            var tempArr: [Card] = sorted1
            if sorted1[i] == sorted1[i + 1] {
                pairVal1 = sorted1[i].rank
                tempArr.remove(at: i + 1)
                tempArr.remove(at: i)
                leftovers1 = tempArr
                break
            }
        }
        
        for i in 0..<sorted2.count {
            var tempArr: [Card] = sorted2
            if sorted2[i] == sorted2[i + 1] {
                pairVal2 = sorted2[i].rank
                tempArr.remove(at: i + 1)
                tempArr.remove(at: i)
                leftovers2 = tempArr
                break
            }
        }
        leftovers1.sort(by: {$0.rank >= $1.rank})
        leftovers1.sort(by: {$0.rank >= $1.rank})
        
        switch pairVal1 == pairVal2 {
        case true:
            break
        default:
            return pairVal1 > pairVal2
        }
        
        for i in 0..<leftovers1.count {
            if leftovers1[i].rank != leftovers2[i].rank {
                return leftovers1[i].rank > leftovers2[i].rank
            }
        }
        
        return nil
    }
    
    private func bothTwoPair(_ hand1: Hand, vs hand2: Hand) -> Bool? {
        guard hand1.handStrength == .twoPair, hand2.handStrength == .twoPair else { fatalError("Tried to pass dissimilar hands for close comparison: Two Pair. Hand1: \(String(describing: hand1.handStrength)) Hand2: \(String(describing: hand2.handStrength))") }
        
        let sorted1 = hand1.cards.sorted(by: {$0.rank <= $1.rank})
        let sorted2 = hand2.cards.sorted(by: {$0.rank <= $1.rank})
        
        var pairs1 = sorted1
        var highcard1Rank: Rank = .two
        for i in 0..<pairs1.count {
            var tempArr = pairs1
            tempArr.remove(at: i)
            if tempArr.contains(pairs1[i]) {
                continue
            } else {
                highcard1Rank = pairs1[i].rank
                pairs1 = tempArr
                break
            }
        }
        var pairs2 = sorted2
        var highcard2Rank: Rank = .two
        for i in 0..<pairs2.count {
            var tempArr = pairs2
            tempArr.remove(at: i)
            if tempArr.contains(pairs2[i]) {
                continue
            } else {
                highcard2Rank = pairs2[i].rank
                pairs2 = tempArr
                break
            }
        }
        
        switch pairs1[3].rank == pairs2[3].rank {
        case true:
            break
        case false:
            return pairs1[3].rank > pairs2[3].rank
        }
        
        switch pairs1[0].rank == pairs2[0].rank {
        case true:
            break
        case false:
            return pairs1[0].rank > pairs2[0].rank
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
        
        let sorted1 = hand1.cards.sorted(by: {$0.rank <= $1.rank})
        let sorted2 = hand2.cards.sorted(by: {$0.rank <= $1.rank})
        var trips1: Rank = .two
        var trips2: Rank = .two
        var leftovers1: [Card] = []
        var leftovers2: [Card] = []
        for i in 1...3 {
            if sorted1[i].rank == sorted1[i - 1].rank && sorted1[i].rank == sorted1[i + 1].rank {
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
            if sorted2[i].rank == sorted2[i - 1].rank &&
                sorted2[i].rank == sorted2[i + 1].rank {
                trips2 = sorted2[i].rank
                for j in 0..<sorted2.count {
                    if sorted2[j].rank != sorted2[i].rank {
                        leftovers2.append(sorted2[j])
                    }
                }
                break
            }
        }
        
        if trips1 != trips2 {
            return trips1 > trips2
        }
        
        leftovers1.sort(by: {$0.rank >= $1.rank})
        leftovers2.sort(by: {$0.rank >= $1.rank})
        
        for i in 0..<leftovers1.count {
            if leftovers1[i].rank != leftovers2[i].rank {
                return leftovers1[i].rank > leftovers2[i].rank
            }
        }
        return nil
    }
    
    private func bothStraight(_ hand1: Hand, vs hand2: Hand) -> Bool? {
        guard hand1.handStrength == .straight, hand2.handStrength == .straight else { fatalError("Tried to pass dissimilar hands for close comparison: Straight. Hand1: \(String(describing: hand1.handStrength)) Hand2: \(String(describing: hand2.handStrength))") }
        
        if hand1.highCard != hand2.highCard {
            return hand1.highCard > hand2.highCard
        }
        
        return nil
    }
    
    private func bothFlush(_ hand1: Hand, vs hand2: Hand) -> Bool? {
        guard hand1.handStrength == .flush, hand2.handStrength == .flush else { fatalError("Tried to pass dissimilar hands for close comparison: Flush. Hand1: \(String(describing: hand1.handStrength)) Hand2: \(String(describing: hand2.handStrength))") }
        
        if hand1.highCard != hand2.highCard {
            return hand1.highCard > hand2.highCard
        }
        
        return nil
    }
    
    private func bothFullHouse(_ hand1: Hand, vs hand2: Hand) -> Bool? {
        guard hand1.handStrength == .fullHouse, hand2.handStrength == .fullHouse else { fatalError("Tried to pass dissimilar hands for close comparison: Full House. Hand1: \(String(describing: hand1.handStrength)) Hand2: \(String(describing: hand2.handStrength))") }
        let sorted1 = hand1.cards.sorted(by: {$0.rank <= $1.rank})
        let sorted2 = hand2.cards.sorted(by: {$0.rank <= $1.rank})
        var trips1: Rank = .two
        var pair1: Rank = .two
        var trips2: Rank = .two
        var pair2: Rank = .two
        
        for i in 1...3 {
            if sorted1[i].rank == sorted1[i - 1].rank && sorted1[i].rank == sorted1[i + 1].rank {
                trips1 = sorted1[i].rank
                var tempArr = sorted1
                for _ in 1...3 {
                    tempArr.remove(at: i - 1)
                }
                pair1 = tempArr[0].rank
            }
        }
        
        for i in 1...3 {
            if sorted2[i].rank == sorted2[i - 1].rank && sorted2[i].rank == sorted2[i + 1].rank {
                trips2 = sorted2[i].rank
                var tempArr = sorted2
                for _ in 1...3 {
                    tempArr.remove(at: i - 1)
                }
                pair2 = tempArr[0].rank
            }
        }
        
        
        if trips1 != trips2 {
            return trips1 > trips2
        }
        
        if pair1 != pair2 {
            return pair1 > pair2
        }
        
        return nil
    }
    
    
    private func bothQuads(_ hand1: Hand, vs hand2: Hand) -> Bool? {
        guard hand1.handStrength == .fourOfAKind, hand2.handStrength == .fourOfAKind else { fatalError("Tried to pass dissimilar hands for close comparison: Four of a Kind. Hand1: \(String(describing: hand1.handStrength)) Hand2: \(String(describing: hand2.handStrength))") }
        let sorted1 = hand1.cards.sorted(by: {$0.rank <= $1.rank})
        let sorted2 = hand2.cards.sorted(by: {$0.rank <= $1.rank})
        
        var quads1: Rank = .two
        var quads2: Rank = .two
        var hi1: Rank = .two
        var hi2: Rank = .two
        
        switch sorted1[0].rank == sorted1[1].rank {
        case true:
            quads1 = sorted1[0].rank
            hi1 = sorted1[4].rank
        case false:
            quads1 = sorted1[4].rank
            hi1 = sorted1[0].rank
        }
        
        switch sorted2[0].rank == sorted2[1].rank {
        case true:
            quads2 = sorted2[0].rank
            hi2 = sorted2[4].rank
        case false:
            quads2 = sorted2[4].rank
            hi2 = sorted2[0].rank
        }
        
        if quads1 != quads2 {
            return quads1 > quads2
        }
        
        if hi1 != hi2 {
            return hi1 > hi2
        }
        
        return nil
    }
    
    private func bothStraightFlush(_ hand1: Hand, vs hand2: Hand) -> Bool? {
        guard hand1.handStrength == .straightFlush, hand2.handStrength == .straightFlush else { fatalError("Tried to pass dissimilar hands for close comparison: Straight Flush. Hand1: \(String(describing: hand1.handStrength)) Hand2: \(String(describing: hand2.handStrength))") }
        
        if hand1.highCard != hand2.highCard {
            return hand1.highCard > hand2.highCard
        }
        
        return nil
    }
}
