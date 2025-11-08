//
//  CategoryRepository.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import Foundation

public protocol CategoryRepository {
    func list(kind: CategoryKind?) async throws -> [Category]
    func save(_ category: Category) async throws
}
