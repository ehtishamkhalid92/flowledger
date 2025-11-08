//
//  Account.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//
import Foundation

public enum AccountKind: String, Codable, CaseIterable { case current, savings, creditCard, cash }

public struct Account: Identifiable, Hashable, Codable {
    public let id: AccountID
    public var name: String
    public var kind: AccountKind
    public var balance: Money

    public init(id: AccountID = UUID().uuidString, name: String, kind: AccountKind, balance: Money) {
        self.id = id; self.name = name; self.kind = kind; self.balance = balance
    }
}
