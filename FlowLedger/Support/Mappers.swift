//
//  Mappers.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import Foundation

// MARK: Account (Domain → UI)

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

// MARK: Transaction (Domain → UI)

func toVM(
    _ t: Transaction,
    accountsById: [AccountID: Account],
    categoriesById: [CategoryID: Category]
) -> TxVM {
    let accName = accountsById[t.accountId]?.name ?? "Account"
    let toName  = t.counterpartyAccountId.flatMap { accountsById[$0]?.name }
    let catName = t.categoryId.flatMap { categoriesById[$0]?.name }

    // Choose an icon: category → fallback by kind
    let icon = t.categoryId
        .flatMap { categoriesById[$0]?.icon }
        ?? {
            switch t.kind {
            case .expense:  return "cart.fill"
            case .income:   return "arrow.down.circle.fill"
            case .transfer: return "arrow.left.arrow.right"
            }
        }()

    return TxVM(
        id: t.id,
        kind: {
            switch t.kind {
            case .expense:  return .expense
            case .income:   return .income
            case .transfer: return .transfer
            }
        }(),
        amountCents: t.amount.cents,
        accountName: accName,
        toAccountName: toName,
        categoryName: catName,
        icon: icon,
        note: t.note,
        date: t.date,
        isCleared: t.isCleared
    )
}
