//
//  UIMapper.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import Foundation

func mapAccountToVM(_ a: Account) -> AccountVM {
    let kind: AccountVM.Kind = {
        switch a.kind {
        case .current: return .current
        case .savings: return .savings
        case .creditCard: return .creditCard
        case .cash: return .cash
        }
    }()
    return AccountVM(id: a.id, name: a.name, kind: kind, balanceCents: a.balance.cents, deltaCents: 0)
}

func mapTransactionToVM(
    _ t: Transaction,
    accountsById: [AccountID: Account],
    categoriesById: [CategoryID: Category]
) -> TxVM {
    let accName = accountsById[t.accountId]?.name ?? "Account"
    let toName  = t.counterpartyAccountId.flatMap { accountsById[$0]?.name }
    let catName = t.categoryId.flatMap { categoriesById[$0]?.name }
    let icon = t.categoryId
        .flatMap { categoriesById[$0]?.icon }
        ?? (t.kind == .expense ? "cart.fill" :
            t.kind == .income  ? "arrow.down.circle.fill" :
                                 "arrow.left.arrow.right.circle.fill")

    let vmKind: TxVM.Kind = (t.kind == .expense ? .expense : t.kind == .income ? .income : .transfer)

    return TxVM(
        id: t.id,
        kind: vmKind,
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

func mapCategoryToVM(_ c: Category) -> CategoryVM {
    CategoryVM(id: c.id, name: c.name, kind: c.kind, icon: c.icon)
}
