//
//  AccountRepository.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import Foundation

public protocol AccountRepository {
    func list() async throws -> [Account]
    func get(id: AccountID) async throws -> Account?
    func save(_ account: Account) async throws
    func delete(id: AccountID) async throws
}
