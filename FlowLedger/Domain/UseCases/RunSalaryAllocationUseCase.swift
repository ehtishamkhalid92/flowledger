//
//  RunSalaryAllocationUseCase.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import Foundation

protocol RunSalaryAllocationUseCase {
    /// Creates transfers/expenses according to the current SalaryPlan for a given salary amount (CHF in cents).
    /// Returns number of transactions created.
    func execute(salaryCents: Int, date: Date) async throws -> Int
}

final class RunSalaryAllocationUC: RunSalaryAllocationUseCase {
    private let accountRepo: AccountRepository
    private let txRepo: TransactionRepository
    private let categoryRepo: CategoryRepository

    init(accountRepo: AccountRepository, txRepo: TransactionRepository, categoryRepo: CategoryRepository) {
        self.accountRepo = accountRepo
        self.txRepo = txRepo
        self.categoryRepo = categoryRepo
    }

    func execute(salaryCents: Int, date: Date) async throws -> Int {
        let plan = SalaryPlanStore.load()

        // ---- Accounts (protocol exposes list() with no arguments)
        let accounts = try await accountRepo.list()
        let accountByName: [String: AccountID] =
            Dictionary(uniqueKeysWithValues: accounts.map { ($0.name, $0.id) })

        // ---- Categories (handle either signature)
        // ---- Categories
        // ---- Categories
        let categories = try await categoryRepo.list(kind: nil as CategoryKind?)
        let categoryByName: [String: CategoryID] =
            Dictionary(uniqueKeysWithValues: categories.map { ($0.name, $0.id) })

        guard let sourceId = accountByName[plan.sourceAccountName] else { return 0 }

        var created = 0

        // Sum percents once to avoid drift
        let percentTotal = plan.items.reduce(0.0) { acc, item in
            if case .percent(let p) = item.amount { return acc + p }
            return acc
        }
        let percentScale = min(percentTotal, 100.0)

        for item in plan.items {
            let portionCents: Int = {
                switch item.amount {
                case .fixedCents(let c): return max(0, c)
                case .percent(let p):
                    let capped = max(0.0, min(100.0, p))
                    let used  = capped / (percentScale == 0 ? 1.0 : percentScale)
                    return Int((Double(salaryCents) * used).rounded())
                }
            }()
            guard portionCents > 0 else { continue }

            switch item.action {
            case .transferToAccount(let targetName):
                guard let targetId = accountByName[targetName] else { continue }
                let tx = Transaction(
                    id: UUID().uuidString,
                    kind: .transfer,
                    amount: Money(cents: portionCents),
                    accountId: sourceId,
                    counterpartyAccountId: targetId,
                    categoryId: nil,
                    note: item.name,
                    date: date,
                    isCleared: true
                )
                try await txRepo.save(tx); created += 1

            case .expenseToCategory(let categoryName):
                guard let categoryId = categoryByName[categoryName] else { continue }
                let tx = Transaction(
                    id: UUID().uuidString,
                    kind: .expense,
                    amount: Money(cents: portionCents),
                    accountId: sourceId,
                    counterpartyAccountId: nil,
                    categoryId: categoryId,
                    note: item.name,
                    date: date,
                    isCleared: true
                )
                try await txRepo.save(tx); created += 1
            }
        }

        return created
    }
}

// Tiny helper
private extension UUID { var string: String { uuidString } }
