//
//  SwiftDataStack.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftData
import SwiftUI

/// Simple SwiftData stack helper + seeding
enum SwiftDataStack {
    static let schema = Schema([
        AccountEntity.self,
        CategoryEntity.self,
        TransactionEntity.self,
        RecurringRuleEntity.self
    ])

    static func modelContainer(inMemory: Bool = false) throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        return try ModelContainer(for: schema, configurations: config)
    }
}

// Optional: quick seeding for testing the repos
@MainActor
func seedIfEmpty(context: ModelContext) throws {
    // Accounts
    let count = try context.fetchCount(FetchDescriptor<AccountEntity>())
    if count == 0 {
        let current = AccountEntity(id: UUID().uuidString, name: "Current", kindRaw: AccountKind.current.rawValue, balanceCents: 285_000)
        let savings = AccountEntity(id: UUID().uuidString, name: "Savings", kindRaw: AccountKind.savings.rawValue, balanceCents: 470_000)
        let credit  = AccountEntity(id: UUID().uuidString, name: "Credit Card", kindRaw: AccountKind.creditCard.rawValue, balanceCents: -30_000)
        context.insert(current); context.insert(savings); context.insert(credit)

        let housing = CategoryEntity(name: "Housing", kindRaw: CategoryKind.expense.rawValue, icon: "house.fill")
        let car     = CategoryEntity(name: "Car", kindRaw: CategoryKind.expense.rawValue, icon: "car.fill")
        let food    = CategoryEntity(name: "Food", kindRaw: CategoryKind.expense.rawValue, icon: "fork.knife")
        let salary  = CategoryEntity(name: "Salary", kindRaw: CategoryKind.income.rawValue, icon: "briefcase.fill")
        context.insert(housing); context.insert(car); context.insert(food); context.insert(salary)

        try context.save()
    }
}
