//
//  RecurringUseCases.swift .swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import Foundation

// Create or update a recurring rule
protocol SaveRecurringRuleUseCase {
    func execute(_ rule: RecurringRule) async throws
}

final class SaveRecurringRuleUC: SaveRecurringRuleUseCase {
    private let repo: RecurringRepository
    init(repo: RecurringRepository) { self.repo = repo }
    func execute(_ rule: RecurringRule) async throws {
        try await repo.save(rule)
    }
}

// Generate transactions for a specific date (idempotent per date+rule)
protocol RunRecurringForDateUseCase {
    func execute(date: Date) async throws -> Int
}

final class RunRecurringForDateUC: RunRecurringForDateUseCase {
    private let recurring: RecurringRepository
    private let tx: TransactionRepository

    init(recurring: RecurringRepository, tx: TransactionRepository) {
        self.recurring = recurring
        self.tx = tx
    }

    func execute(date: Date) async throws -> Int {
        let rules = try await recurring.listActive()
        let gen = try await generateTransactions(for: date, rules: rules)
        for t in gen { try await tx.save(t) }
        return gen.count
    }

    // MARK: - Matching logic

    private func matches(_ rule: RecurringRule, date: Date) -> Bool {
        let cal = Calendar.current
        // respect start/end
        if date < startOfDay(rule.startDate) { return false }
        if let end = rule.endDate, date > endOfDay(end) { return false }

        switch rule.recurrence {
        case .monthly(let day):
            // clamp day to last day of month
            let dayInMonth = min(day, cal.range(of: .day, in: .month, for: date)!.count)
            return cal.component(.day, from: date) == dayInMonth
        case .weekly(let weekday):
            // weekday: 1...7 (Sun=1)
            return cal.component(.weekday, from: date) == weekday
        }
    }

    private func generateTransactions(for date: Date, rules: [RecurringRule]) async throws -> [Transaction] {
        let filtered = rules.filter { matches($0, date: date) }
        return filtered.map { r in
            Transaction(
                id: UUID().uuidString,
                kind: r.template.kind,
                amount: r.template.amount,
                accountId: r.template.accountId,
                counterpartyAccountId: r.template.counterpartyAccountId,
                categoryId: r.template.categoryId,
                note: r.template.note ?? r.name,
                date: date,
                isCleared: true
            )
        }
    }

    private func startOfDay(_ d: Date) -> Date {
        Calendar.current.startOfDay(for: d)
    }
    private func endOfDay(_ d: Date) -> Date {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: d)!
    }
}
