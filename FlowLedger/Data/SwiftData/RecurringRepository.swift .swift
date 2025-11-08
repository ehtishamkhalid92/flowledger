//
//  RecurringRepository.swift .swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import Foundation
import SwiftData

final class SDRecurringRepository: RecurringRepository {
    private let ctx: ModelContext
    init(ctx: ModelContext) { self.ctx = ctx }

    func listActive() async throws -> [RecurringRule] {
        var fetch = FetchDescriptor<RecurringRuleEntity>(
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        // simple: include all; you can filter by endDate later
        let rows = try ctx.fetch(fetch)
        return rows.map { $0.toDomain() }
    }

    func save(_ rule: RecurringRule) async throws {
        if let entity = try findEntity(id: rule.id) {
            entity.name = rule.name
            entity.templateKindRaw = rule.template.kind.rawValue
            entity.templateAmountCents = rule.template.amount.cents
            entity.templateAccountId = rule.template.accountId
            entity.templateCounterpartyId = rule.template.counterpartyAccountId
            entity.templateCategoryId = rule.template.categoryId
            entity.templateNote = rule.template.note
            entity.recurrenceRaw = Self.encode(recurrence: rule.recurrence)
            entity.startDate = rule.startDate
            entity.endDate = rule.endDate
        } else {
            let e = RecurringRuleEntity(
                id: rule.id,
                name: rule.name,
                templateKindRaw: rule.template.kind.rawValue,
                templateAmountCents: rule.template.amount.cents,
                templateAccountId: rule.template.accountId,
                templateCounterpartyId: rule.template.counterpartyAccountId,
                templateCategoryId: rule.template.categoryId,
                templateNote: rule.template.note,
                recurrenceRaw: Self.encode(recurrence: rule.recurrence),
                startDate: rule.startDate,
                endDate: rule.endDate
            )
            ctx.insert(e)
        }
        try ctx.save()
    }

    func delete(id: RecurringID) async throws {
        if let e = try findEntity(id: id) {
            ctx.delete(e)
            try ctx.save()
        }
    }

    // MARK: - Helpers

    private func findEntity(id: String) throws -> RecurringRuleEntity? {
        let predicate = #Predicate<RecurringRuleEntity> { $0.id == id }
        var fetch = FetchDescriptor<RecurringRuleEntity>(predicate: predicate)
        fetch.fetchLimit = 1
        return try ctx.fetch(fetch).first
    }

    private static func encode(recurrence: Recurrence) -> String {
        switch recurrence {
        case .monthly(let day): return "monthly:\(day)"
        case .weekly(let weekday): return "weekly:\(weekday)"
        }
    }
}
