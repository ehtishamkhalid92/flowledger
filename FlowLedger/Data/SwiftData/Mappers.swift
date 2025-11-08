//
//  Mappers.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import Foundation

// Domain → SwiftData
extension AccountEntity {
    convenience init(from domain: Account) {
        self.init(id: domain.id, name: domain.name, kindRaw: domain.kind.rawValue, balanceCents: domain.balance.cents)
    }
    func toDomain() -> Account {
        Account(id: id, name: name, kind: AccountKind(rawValue: kindRaw) ?? .current, balance: Money(cents: balanceCents))
    }
}

extension CategoryEntity {
    convenience init(from domain: Category) {
        self.init(id: domain.id, name: domain.name, kindRaw: domain.kind.rawValue, icon: domain.icon)
    }
    func toDomain() -> Category {
        Category(id: id, name: name, kind: CategoryKind(rawValue: kindRaw) ?? .expense, icon: icon)
    }
}

extension TransactionEntity {
    func toDomain() -> Transaction {
        Transaction(
            id: id,
            kind: TransactionKind(rawValue: kindRaw) ?? .expense,
            amount: Money(cents: amountCents),
            accountId: account.id,
            counterpartyAccountId: counterparty?.id,
            categoryId: category?.id,
            note: note,
            date: date,
            isCleared: isCleared
        )
    }
}

extension RecurringRuleEntity {
    func toDomain() -> RecurringRule {
        let recurrence: Recurrence = {
            if recurrenceRaw.hasPrefix("monthly:"),
               let d = Int(recurrenceRaw.split(separator: ":").last ?? "") { return .monthly(day: d) }
            if recurrenceRaw.hasPrefix("weekly:"),
               let w = Int(recurrenceRaw.split(separator: ":").last ?? "") { return .weekly(weekday: w) }
            return .monthly(day: 1)
        }()

        let template = Transaction(
            kind: TransactionKind(rawValue: templateKindRaw) ?? .expense,
            amount: Money(cents: templateAmountCents),
            accountId: templateAccountId,
            counterpartyAccountId: templateCounterpartyId,
            categoryId: templateCategoryId,
            note: templateNote,
            date: Date(),
            isCleared: true
        )

        return RecurringRule(
            id: id, name: name, template: template,
            recurrence: recurrence, startDate: startDate, endDate: endDate
        )
    }
}
