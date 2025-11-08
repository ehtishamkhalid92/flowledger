//
//  Models.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import Foundation
import SwiftData

// MARK: - Account

@Model
final class AccountEntity {
    @Attribute(.unique) var id: String
    var name: String
    var kindRaw: String          // AccountKind rawValue
    var balanceCents: Int

    @Relationship(deleteRule: .cascade, inverse: \TransactionEntity.account)
    var transactions: [TransactionEntity] = []

    init(id: String = UUID().uuidString, name: String, kindRaw: String, balanceCents: Int) {
        self.id = id
        self.name = name
        self.kindRaw = kindRaw
        self.balanceCents = balanceCents
    }
}

// MARK: - Category

@Model
final class CategoryEntity {
    @Attribute(.unique) var id: String
    var name: String
    var kindRaw: String          // CategoryKind rawValue
    var icon: String

    @Relationship(deleteRule: .nullify, inverse: \TransactionEntity.category)
    var transactions: [TransactionEntity]? = []

    init(id: String = UUID().uuidString, name: String, kindRaw: String, icon: String) {
        self.id = id
        self.name = name
        self.kindRaw = kindRaw
        self.icon = icon
    }
}

// MARK: - Transaction

@Model
final class TransactionEntity {
    @Attribute(.unique) var id: String
    var kindRaw: String          // TransactionKind rawValue
    var amountCents: Int
    var note: String?
    var date: Date
    var isCleared: Bool

    // Relations
    @Relationship var account: AccountEntity
    @Relationship var counterparty: AccountEntity?   // for transfers
    @Relationship var category: CategoryEntity?

    init(
        id: String = UUID().uuidString,
        kindRaw: String,
        amountCents: Int,
        account: AccountEntity,
        counterparty: AccountEntity? = nil,
        category: CategoryEntity? = nil,
        note: String? = nil,
        date: Date,
        isCleared: Bool
    ) {
        self.id = id
        self.kindRaw = kindRaw
        self.amountCents = amountCents
        self.account = account
        self.counterparty = counterparty
        self.category = category
        self.note = note
        self.date = date
        self.isCleared = isCleared
    }
}

// MARK: - Recurring (kept simple)

@Model
final class RecurringRuleEntity {
    @Attribute(.unique) var id: String
    var name: String

    // template fields (flattened so we don’t need deep graphs for now)
    var templateKindRaw: String
    var templateAmountCents: Int
    var templateAccountId: String
    var templateCounterpartyId: String?
    var templateCategoryId: String?
    var templateNote: String?

    var recurrenceRaw: String   // "monthly:15" / "weekly:2"
    var startDate: Date
    var endDate: Date?

    init(
        id: String = UUID().uuidString,
        name: String,
        templateKindRaw: String,
        templateAmountCents: Int,
        templateAccountId: String,
        templateCounterpartyId: String?,
        templateCategoryId: String?,
        templateNote: String?,
        recurrenceRaw: String,
        startDate: Date,
        endDate: Date?
    ) {
        self.id = id
        self.name = name
        self.templateKindRaw = templateKindRaw
        self.templateAmountCents = templateAmountCents
        self.templateAccountId = templateAccountId
        self.templateCounterpartyId = templateCounterpartyId
        self.templateCategoryId = templateCategoryId
        self.templateNote = templateNote
        self.recurrenceRaw = recurrenceRaw
        self.startDate = startDate
        self.endDate = endDate
    }
}
