//
//  SalaryPlanStore.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import Foundation

// MARK: - Models

enum AllocationAmount: Codable, Equatable {
    case percent(Double)     // 0...100
    case fixedCents(Int)     // e.g. 120_00

    var isPercent: Bool {
        if case .percent = self { return true } else { return false }
    }
}

enum AllocationAction: Codable, Equatable {
    case transferToAccount(targetAccountName: String)     // source -> target
    case expenseToCategory(categoryName: String)          // spend from source
}

struct SalaryAllocationItem: Codable, Identifiable, Equatable {
    var id: String = UUID().uuidString
    var name: String
    var action: AllocationAction
    var amount: AllocationAmount
}

struct SalaryPlan: Codable, Equatable {
    var sourceAccountName: String
    var items: [SalaryAllocationItem]
}

// MARK: - Store

enum SalaryPlanStore {
    private static let key = "settings.salary.plan.v1"
    private static let encoder = JSONEncoder()
    private static let decoder = JSONDecoder()

    static func load() -> SalaryPlan {
        if let data = UserDefaults.standard.data(forKey: key),
           let plan = try? decoder.decode(SalaryPlan.self, from: data) {
            return plan
        }
        // Default starter plan (tweak freely)
        let plan = SalaryPlan(
            sourceAccountName: "Current",
            items: [
                SalaryAllocationItem(
                    name: "Savings (Emergency Fund)",
                    action: .transferToAccount(targetAccountName: "Savings"),
                    amount: .percent(60)
                ),
                SalaryAllocationItem(
                    name: "Credit-card payoff",
                    action: .expenseToCategory(categoryName: "Credit Card"),
                    amount: .fixedCents(300_00)
                ),
                SalaryAllocationItem(
                    name: "Children’s Fund",
                    action: .transferToAccount(targetAccountName: "Savings"),
                    amount: .fixedCents(120_00)
                )
            ]
        )
        save(plan)
        return plan
    }

    static func save(_ plan: SalaryPlan) {
        if let data = try? encoder.encode(plan) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
