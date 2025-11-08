//
//  DI.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import Foundation

enum DI {
    static let accountRepo: AccountRepository = InMemoryAccountRepo()
    static let txRepo: TransactionRepository = InMemoryTxRepo()
    static let categoryRepo: CategoryRepository = InMemoryCategoryRepo()

    static let addExpense: AddExpenseUseCase = AddExpenseUC(tx: txRepo)
    static let addIncome: AddIncomeUseCase  = AddIncomeUC(tx: txRepo)
    static let transfer: TransferUseCase    = TransferUC(tx: txRepo)
    static let monthSummary: MonthSummaryUseCase = MonthSummaryUC(tx: txRepo)
    static let listAccounts: ListAccountsUseCase = ListAccountsUC(repo: accountRepo)
    static let createAccount: CreateAccountUseCase = CreateAccountUC(repo: accountRepo)
}
