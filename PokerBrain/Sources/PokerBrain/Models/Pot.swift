//
//  File.swift
//  
//
//  Created by Cody Morley on 5/12/21.
//

import Foundation

struct Pot {
    private(set) var mainPot: Double = 0
    private(set) var sidePots: [Pot] = []
    private(set) var players: [Player] = [Player]()
    var total: Double { mainPot + sidePotsTotal }
    var sidePotsTotal: Double {
        var total: Double = 0
        for pot in sidePots {
            total += pot.mainPot
        }
        return total
    }
    var sidePotCount: Int { return sidePots.count }
    var hasSidePots: Bool { return sidePotCount > 0 }
    
    
    
    
    public mutating func addPlayer(_ player: Player) {
        players.append(player)
        players.sort(by: {$0.seat < $1.seat})
    }
    
    public mutating func removePlayer(_ player: Player) {
        if let playerIndex = players.firstIndex(of: player) {
            players.remove(at: playerIndex)
        }
        
        if !sidePots.isEmpty {
            for var pot in sidePots {
                if let playerIndex = pot.players.firstIndex(of: player) {
                    pot.players.remove(at: playerIndex)
                }
            }
        }
    }
    
    public mutating func addToPot(_ amount: Double, shouldStartSidePot: Bool, removingPlayer: Player?) {
        switch hasSidePots {
        case true:
            switch shouldStartSidePot {
            case true:
                if var last = sidePots.last {
                    last.mainPot += amount
                }
                let sidePlayers = players.filter({$0 != removingPlayer})
                let sidePot = Pot(mainPot: 0, sidePots: [], players: sidePlayers)
                sidePots.append(sidePot)
            case false:
                if var last = sidePots.last {
                    last.mainPot += amount
                }
            }
        case false:
            switch shouldStartSidePot {
            case true:
                mainPot += amount
                let sidePlayers = players.filter({$0 != removingPlayer})
                let sidePot = Pot(mainPot: 0, sidePots: [], players: sidePlayers)
                sidePots.append(sidePot)
            case false:
                mainPot += amount
            }
        }
    }
    
    public mutating func payOut() -> [UUID : Double] {
        var payouts = [UUID : Double]()
        var paidPlayers = Set<UUID>()
        
        while hasSidePots {
            if var last = sidePots.last {
                let potPlayers = last.players.count
                let leftover = Int(last.mainPot) % potPlayers
                if sidePots.count > 1 {
                    sidePots[sidePots.endIndex - 1].mainPot += Double(leftover)
                } else {
                    mainPot += Double(leftover)
                }
                last.mainPot -= Double(leftover)
                
                let prizeAmount = last.mainPot / Double(potPlayers)
                for player in last.players {
                    let id = player.id
                    if !paidPlayers.contains(id) {
                        paidPlayers.insert(id)
                        payouts[id] = 0
                    }
                    payouts[id]? += prizeAmount
                    last.mainPot -= prizeAmount
                }
            }
            sidePots.remove(at: sidePots.endIndex)
        }
        let potPlayers = players.count
        let leftover = Int(mainPot) % potPlayers
        let splittingAmount: Double = mainPot - Double(leftover)
        let prizeAmount = splittingAmount / Double(players.count)
        
        for player in players {
            let id = player.id
            if !paidPlayers.contains(id) {
                paidPlayers.insert(id)
                payouts[id] = 0
            }
            payouts[id]? += prizeAmount
            mainPot -= prizeAmount
        }
        mainPot += Double(leftover)
        
        return payouts
    }
}
