//
//  FakeRepositories.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import Foundation

final class InMemoryAccountRepo: AccountRepository {
    private var accounts: [AccountID: Account] = {
        let a1 = Account(name: "Current", kind: .current, balance: Money(cents: 285_000))
        let a2 = Account(name: "Savings", kind: .savings, balance: Money(cents: 470_000))
        let a3 = Account(name: "Credit Card", kind: .creditCard, balance: Money(cents: -30_000))
        let a4 = Account(name: "Cash", kind: .cash, balance: Money(cents: 1_500))
        return [a1.id:a1, a2.id:a2, a3.id:a3, a4.id:a4]
    }()
    func list() async throws -> [Account] { Array(accounts.values) }
    func get(id: AccountID) async throws -> Account? { accounts[id] }
    func save(_ account: Account) async throws { accounts[account.id] = account }
    func delete(id: AccountID) async throws { accounts.removeValue(forKey: id) }
}

final class InMemoryTxRepo: TransactionRepository {
    private var items: [Transaction] = []
    func list(query: TxQuery) async throws -> [Transaction] {
        var r = items
        if let month = query.month {
            let cal = Calendar.current
            let start = cal.date(from: cal.dateComponents([.year, .month], from: month))!
            let end = cal.date(byAdding: .month, value: 1, to: start)!
            r = r.filter { $0.date >= start && $0.date < end }
        }
        if let acc = query.accountId { r = r.filter { $0.accountId == acc || $0.counterpartyAccountId == acc } }
        if let cat = query.categoryId { r = r.filter { $0.categoryId == cat } }
        if query.clearedOnly { r = r.filter { $0.isCleared } }
        if !query.search.isEmpty { r = r.filter { ($0.note ?? "").localizedCaseInsensitiveContains(query.search) } }
        return r.sorted(by: { $0.date > $1.date })
    }
    func save(_ tx: Transaction) async throws { items.removeAll { $0.id == tx.id }; items.append(tx) }
    func delete(id: TransactionID) async throws { items.removeAll { $0.id == id } }
}

final class InMemoryCategoryRepo: CategoryRepository {
    private var cats: [Category] = [
        .init(name: "Housing", kind: .expense, icon: "house.fill"),
        .init(name: "Car", kind: .expense, icon: "car.fill"),
        .init(name: "Insurance", kind: .expense, icon: "stethoscope"),
        .init(name: "Food", kind: .expense, icon: "fork.knife"),
        .init(name: "Salary", kind: .income, icon: "briefcase.fill")
    ]
    func list(kind: CategoryKind?) async throws -> [Category] {
        guard let k = kind else { return cats }
        return cats.filter { $0.kind == k }
    }
    func save(_ category: Category) async throws { cats.removeAll { $0.id == category.id }; cats.append(category) }
}
