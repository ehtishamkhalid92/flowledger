//
//  TransactionRepository.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import Foundation

public struct TxQuery {
    public var month: Date?
    public var accountId: AccountID?
    public var categoryId: CategoryID?
    public var clearedOnly: Bool = false
    public var search: String = ""
    public init() {}
}

public protocol TransactionRepository {
    func list(query: TxQuery) async throws -> [Transaction]
    func save(_ tx: Transaction) async throws
    func delete(id: TransactionID) async throws
}
