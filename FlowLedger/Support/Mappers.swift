//
//  Mappers.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import Foundation

// UI VM from Domain Account
func toVM(_ a: Account) -> AccountVM {
    AccountVM(
        id: a.id,
        name: a.name,
        kind: {
            switch a.kind {
            case .current:    return .current
            case .savings:    return .savings
            case .creditCard: return .creditCard
            case .cash:       return .cash
            }
        }(),
        balanceCents: a.balance.cents,
        deltaCents: 0
    )
}
