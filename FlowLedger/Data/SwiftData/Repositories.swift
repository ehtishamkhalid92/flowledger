//
//  Repositories.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import Foundation
import SwiftData

// MARK: - AccountRepository

final class SDAccountRepository: AccountRepository {
    private let ctx: ModelContext
    init(ctx: ModelContext) { self.ctx = ctx }

    func list() async throws -> [Account] {
        let fetch = FetchDescriptor<AccountEntity>(
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        let rows = try ctx.fetch(fetch)
        return rows.map { $0.toDomain() }
    }

    func get(id: AccountID) async throws -> Account? {
        let predicate = #Predicate<AccountEntity> { $0.id == id }
        var fetch = FetchDescriptor<AccountEntity>(predicate: predicate)
        fetch.fetchLimit = 1
        return try ctx.fetch(fetch).first?.toDomain()
    }

    func save(_ account: Account) async throws {
        if let existing = try findEntity(id: account.id) {
            existing.name = account.name
            existing.kindRaw = account.kind.rawValue
            existing.balanceCents = account.balance.cents
        } else {
            ctx.insert(AccountEntity(from: account))
        }
        try ctx.save()
    }

    func delete(id: AccountID) async throws {
        if let entity = try findEntity(id: id) {
            ctx.delete(entity)
            try ctx.save()
        }
    }

    private func findEntity(id: String) throws -> AccountEntity? {
        let predicate = #Predicate<AccountEntity> { $0.id == id }
        var fetch = FetchDescriptor<AccountEntity>(predicate: predicate)
        fetch.fetchLimit = 1
        return try ctx.fetch(fetch).first
    }
}

// MARK: - CategoryRepository

final class SDCategoryRepository: CategoryRepository {
    private let ctx: ModelContext
    init(ctx: ModelContext) { self.ctx = ctx }

    func list(kind: CategoryKind?) async throws -> [Category] {
        var fetch = FetchDescriptor<CategoryEntity>(
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        if let kind {
            fetch.predicate = #Predicate { $0.kindRaw == kind.rawValue }
        }
        return try ctx.fetch(fetch).map { $0.toDomain() }
    }

    func save(_ category: Category) async throws {
        if let entity = try findEntity(id: category.id) {
            entity.name = category.name
            entity.kindRaw = category.kind.rawValue
            entity.icon = category.icon
        } else {
            ctx.insert(CategoryEntity(from: category))
        }
        try ctx.save()
    }

    private func findEntity(id: String) throws -> CategoryEntity? {
        let predicate = #Predicate<CategoryEntity> { $0.id == id }
        var fetch = FetchDescriptor<CategoryEntity>(predicate: predicate)
        fetch.fetchLimit = 1
        return try ctx.fetch(fetch).first
    }
}

// MARK: - TransactionRepository

final class SDTransactionRepository: TransactionRepository {
    private let ctx: ModelContext
    init(ctx: ModelContext) { self.ctx = ctx }

    func list(query: TxQuery) async throws -> [Transaction] {
        var predicate: Predicate<TransactionEntity> = #Predicate { _ in true }

        if let month = query.month {
            let cal = Calendar.current
            let start = cal.date(from: cal.dateComponents([.year, .month], from: month))!
            let end = cal.date(byAdding: .month, value: 1, to: start)!
            predicate = #Predicate {
                $0.date >= start && $0.date < end
            }
        }

        let fetch = FetchDescriptor<TransactionEntity>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        let rows = try ctx.fetch(fetch)

        // Apply remaining filters in-memory (fine for local data scale)
        let filtered = rows.filter { row in
            (!query.clearedOnly || row.isCleared) &&
            (query.accountId == nil || row.account.id == query.accountId || row.counterparty?.id == query.accountId) &&
            (query.categoryId == nil || row.category?.id == query.categoryId) &&
            (query.search.isEmpty || (row.note ?? "").localizedCaseInsensitiveContains(query.search))
        }

        return filtered.map { $0.toDomain() }
    }

    func save(_ tx: Transaction) async throws {
        // Load relations
        guard let account = try findAccount(id: tx.accountId) else { throw DomainError.notFound }
        let counterparty = try tx.counterpartyAccountId.flatMap { try findAccount(id: $0) }
        let category = try tx.categoryId.flatMap { try findCategory(id: $0) }

        if let existing = try findTx(id: tx.id) {
            existing.kindRaw = tx.kind.rawValue
            existing.amountCents = tx.amount.cents
            existing.account = account
            existing.counterparty = counterparty
            existing.category = category
            existing.note = tx.note
            existing.date = tx.date
            existing.isCleared = tx.isCleared
        } else {
            let entity = TransactionEntity(
                id: tx.id,
                kindRaw: tx.kind.rawValue,
                amountCents: tx.amount.cents,
                account: account,
                counterparty: counterparty,
                category: category,
                note: tx.note,
                date: tx.date,
                isCleared: tx.isCleared
            )
            ctx.insert(entity)
        }
        try ctx.save()
    }

    func delete(id: TransactionID) async throws {
        if let entity = try findTx(id: id) {
            ctx.delete(entity)
            try ctx.save()
        }
    }

    // MARK: helpers

    private func findTx(id: String) throws -> TransactionEntity? {
        let predicate = #Predicate<TransactionEntity> { $0.id == id }
        var fetch = FetchDescriptor<TransactionEntity>(predicate: predicate)
        fetch.fetchLimit = 1
        return try ctx.fetch(fetch).first
    }

    private func findAccount(id: String) throws -> AccountEntity? {
        let predicate = #Predicate<AccountEntity> { $0.id == id }
        var fetch = FetchDescriptor<AccountEntity>(predicate: predicate)
        fetch.fetchLimit = 1
        return try ctx.fetch(fetch).first
    }

    private func findCategory(id: String) throws -> CategoryEntity? {
        let predicate = #Predicate<CategoryEntity> { $0.id == id }
        var fetch = FetchDescriptor<CategoryEntity>(predicate: predicate)
        fetch.fetchLimit = 1
        return try ctx.fetch(fetch).first
    }
}
