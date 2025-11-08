//
//  RecurringRule.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import Foundation

public enum Recurrence: Equatable, Hashable, Codable {
    case monthly(day: Int)       // 1...28/30/31
    case weekly(weekday: Int)    // 1...7 (Sun=1)
}

public struct RecurringRule: Identifiable, Hashable, Codable {
    public let id: RecurringID
    public var name: String
    public var template: Transaction      // amount/kind/account/category prefilled
    public var recurrence: Recurrence
    public var startDate: Date
    public var endDate: Date?

    public init(
        id: RecurringID = UUID().uuidString,
        name: String,
        template: Transaction,
        recurrence: Recurrence,
        startDate: Date,
        endDate: Date? = nil
    ) {
        self.id = id; self.name = name; self.template = template
        self.recurrence = recurrence; self.startDate = startDate; self.endDate = endDate
    }
}
