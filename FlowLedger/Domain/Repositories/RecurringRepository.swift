//
//  RecurringRepository.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import Foundation

public protocol RecurringRepository {
    func listActive() async throws -> [RecurringRule]
    func save(_ rule: RecurringRule) async throws
    func delete(id: RecurringID) async throws
}
