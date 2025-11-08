//
//  DI.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import Foundation
import SwiftData

// MARK: - Temporary In-Memory Recurring Repo (for boot before SwiftData setup)
final class InMemoryRecurringRepo: RecurringRepository {
    func listActive() async throws -> [RecurringRule] { [] }
    func save(_ rule: RecurringRule) async throws {}
    func delete(id: RecurringID) async throws {}
}

// MARK: - Dependency Injection Container

enum DI {
    // MARK: - Repositories
    static var accountRepo: AccountRepository = InMemoryAccountRepo()
    static var txRepo: TransactionRepository = InMemoryTxRepo()
    static var categoryRepo: CategoryRepository = InMemoryCategoryRepo()
    static var recurringRepo: RecurringRepository = InMemoryRecurringRepo()

    // MARK: - Use Cases
    static var addExpense: AddExpenseUseCase = AddExpenseUC(tx: txRepo)
    static var addIncome: AddIncomeUseCase = AddIncomeUC(tx: txRepo)
    static var transfer: TransferUseCase = TransferUC(tx: txRepo)
    static var monthSummary: MonthSummaryUseCase = MonthSummaryUC(tx: txRepo)
    static var listAccounts: ListAccountsUseCase = ListAccountsUC(repo: accountRepo)
    static var createAccount: CreateAccountUseCase = CreateAccountUC(repo: accountRepo)

    static var saveRecurring: SaveRecurringRuleUseCase = SaveRecurringRuleUC(repo: recurringRepo)
    static var runRecurringForDate: RunRecurringForDateUseCase = RunRecurringForDateUC(recurring: recurringRepo, tx: txRepo)
    static var runSalaryAllocation: RunSalaryAllocationUseCase = RunSalaryAllocationUC(
        accountRepo: accountRepo, txRepo: txRepo, categoryRepo: categoryRepo
    )

    // MARK: - SwiftData Configuration
    static func useSwiftData(context: ModelContext) {
        let acc = SDAccountRepository(ctx: context)
        let tx = SDTransactionRepository(ctx: context)
        let cat = SDCategoryRepository(ctx: context)
        let rec = SDRecurringRepository(ctx: context)

        // Repositories
        accountRepo = acc
        txRepo = tx
        categoryRepo = cat
        recurringRepo = rec

        // Use Cases
        addExpense = AddExpenseUC(tx: tx)
        addIncome = AddIncomeUC(tx: tx)
        transfer = TransferUC(tx: tx)
        monthSummary = MonthSummaryUC(tx: tx)
        listAccounts = ListAccountsUC(repo: acc)
        createAccount = CreateAccountUC(repo: acc)

        saveRecurring = SaveRecurringRuleUC(repo: rec)
        runRecurringForDate = RunRecurringForDateUC(recurring: rec, tx: tx)
        runSalaryAllocation = RunSalaryAllocationUC(accountRepo: acc, txRepo: tx, categoryRepo: cat)
    }
}
