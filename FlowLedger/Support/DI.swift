//
//  DI.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import Foundation
import SwiftData

// MARK: - Simple service locator for this app.
// Starts with in-memory fakes; BootstrapDI will switch to SwiftData repos at runtime.

enum DI {
    // Repositories
    static var accountRepo: AccountRepository = InMemoryAccountRepo()
    static var txRepo: TransactionRepository = InMemoryTxRepo()
    static var categoryRepo: CategoryRepository = InMemoryCategoryRepo()
    static var recurringRepo: RecurringRepository = {
        // Not implemented in SwiftData yet; keep in-memory later if needed.
        InMemoryRecurringRepo()
    }()

    // Use cases
    static var addExpense: AddExpenseUseCase = AddExpenseUC(tx: txRepo)
    static var addIncome:  AddIncomeUseCase  = AddIncomeUC(tx: txRepo)
    static var transfer:   TransferUseCase   = TransferUC(tx: txRepo)
    static var monthSummary: MonthSummaryUseCase = MonthSummaryUC(tx: txRepo)
    static var listAccounts: ListAccountsUseCase = ListAccountsUC(repo: accountRepo)
    static var createAccount: CreateAccountUseCase = CreateAccountUC(repo: accountRepo)

    /// Call once at app start (from a View that has a ModelContext) to switch DI to SwiftData.
    static func useSwiftData(context: ModelContext) {
        // Repositories
        let acc  = SDAccountRepository(ctx: context)
        let tx   = SDTransactionRepository(ctx: context)
        let cat  = SDCategoryRepository(ctx: context)

        accountRepo  = acc
        txRepo       = tx
        categoryRepo = cat
        // recurringRepo: keep as-is until we add SD impl

        // Recreate use-cases with SD repos
        addExpense   = AddExpenseUC(tx: tx)
        addIncome    = AddIncomeUC(tx: tx)
        transfer     = TransferUC(tx: tx)
        monthSummary = MonthSummaryUC(tx: tx)
        listAccounts = ListAccountsUC(repo: acc)
        createAccount = CreateAccountUC(repo: acc)
    }
}

// Temporary placeholder so DI compiles; implement later if needed.
final class InMemoryRecurringRepo: RecurringRepository {
    func listActive() async throws -> [RecurringRule] { [] }
    func save(_ rule: RecurringRule) async throws {}
    func delete(id: RecurringID) async throws {}
}
