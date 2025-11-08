//
//  Transaction.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import Foundation

public enum TransactionKind: String, Codable { case expense, income, transfer }

public struct Transaction: Identifiable, Hashable, Codable {
    public let id: TransactionID
    public var kind: TransactionKind
    public var amount: Money               // positive amount; sign comes from kind
    public var accountId: AccountID        // source account for expense/transfer, target for income
    public var counterpartyAccountId: AccountID? // target for transfer
    public var categoryId: CategoryID?     // nil for transfer
    public var note: String?
    public var date: Date
    public var isCleared: Bool

    public init(
        id: TransactionID = UUID().uuidString,
        kind: TransactionKind,
        amount: Money,
        accountId: AccountID,
        counterpartyAccountId: AccountID? = nil,
        categoryId: CategoryID? = nil,
        note: String? = nil,
        date: Date,
        isCleared: Bool
    ) {
        self.id = id; self.kind = kind; self.amount = amount
        self.accountId = accountId; self.counterpartyAccountId = counterpartyAccountId
        self.categoryId = categoryId; self.note = note
        self.date = date; self.isCleared = isCleared
    }
}
