//
//  FakeUseCases.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import Foundation

final class AddExpenseUC: AddExpenseUseCase {
    private let tx: TransactionRepository
    init(tx: TransactionRepository) { self.tx = tx }
    func execute(amount: Money, accountId: AccountID, categoryId: CategoryID, note: String?, date: Date, cleared: Bool) async throws {
        let t = Transaction(kind: .expense, amount: amount, accountId: accountId, categoryId: categoryId, note: note, date: date, isCleared: cleared)
        try await tx.save(t)
    }
}

final class AddIncomeUC: AddIncomeUseCase {
    private let tx: TransactionRepository
    init(tx: TransactionRepository) { self.tx = tx }
    func execute(amount: Money, accountId: AccountID, categoryId: CategoryID, note: String?, date: Date, cleared: Bool) async throws {
        let t = Transaction(kind: .income, amount: amount, accountId: accountId, categoryId: categoryId, note: note, date: date, isCleared: cleared)
        try await tx.save(t)
    }
}

final class TransferUC: TransferUseCase {
    private let tx: TransactionRepository
    init(tx: TransactionRepository) { self.tx = tx }
    func execute(amount: Money, from fromAccountId: AccountID, to toAccountId: AccountID, note: String?, date: Date, cleared: Bool) async throws {
        let t = Transaction(kind: .transfer, amount: amount, accountId: fromAccountId, counterpartyAccountId: toAccountId, note: note, date: date, isCleared: cleared)
        try await tx.save(t)
    }
}

final class MonthSummaryUC: MonthSummaryUseCase {
    private let tx: TransactionRepository
    init(tx: TransactionRepository) { self.tx = tx }
    func execute(month: Date) async throws -> (income: Money, expense: Money, net: Money) {
        var q = TxQuery(); q.month = month
        let items = try await tx.list(query: q)
        let inc = items.filter { $0.kind == .income  }.reduce(0) { $0 + $1.amount.cents }
        let exp = items.filter { $0.kind == .expense }.reduce(0) { $0 + $1.amount.cents }
        return (Money(cents: inc), Money(cents: exp), Money(cents: inc - exp))
    }
}

final class ListAccountsUC: ListAccountsUseCase {
    private let repo: AccountRepository
    init(repo: AccountRepository) { self.repo = repo }
    func execute() async throws -> [Account] { try await repo.list() }
}

final class CreateAccountUC: CreateAccountUseCase {
    private let repo: AccountRepository
    init(repo: AccountRepository) { self.repo = repo }
    func execute(name: String, kind: AccountKind, openingBalance: Money) async throws -> Account {
        var a = Account(name: name, kind: kind, balance: openingBalance)
        try await repo.save(a)
        return a
    }
}
