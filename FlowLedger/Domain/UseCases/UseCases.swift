//
//  UseCases.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import Foundation

public protocol AddExpenseUseCase {
    func execute(amount: Money, accountId: AccountID, categoryId: CategoryID, note: String?, date: Date, cleared: Bool) async throws
}
public protocol AddIncomeUseCase {
    func execute(amount: Money, accountId: AccountID, categoryId: CategoryID, note: String?, date: Date, cleared: Bool) async throws
}
public protocol TransferUseCase {
    func execute(amount: Money, from fromAccountId: AccountID, to toAccountId: AccountID, note: String?, date: Date, cleared: Bool) async throws
}
public protocol MonthSummaryUseCase {
    func execute(month: Date) async throws -> (income: Money, expense: Money, net: Money)
}
public protocol ListAccountsUseCase {
    func execute() async throws -> [Account]
}
public protocol CreateAccountUseCase {
    func execute(name: String, kind: AccountKind, openingBalance: Money) async throws -> Account
}
