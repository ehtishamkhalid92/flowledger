//
//  Money.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import Foundation

public struct Money: Hashable, Codable {
    public let cents: Int
    public let currency: String  // "CHF" by default
    public init(cents: Int, currency: String = "CHF") {
        self.cents = cents
        self.currency = currency
    }
    public static let zero = Money(cents: 0)
    public static func + (lhs: Money, rhs: Money) -> Money { Money(cents: lhs.cents + rhs.cents, currency: lhs.currency) }
    public static func - (lhs: Money, rhs: Money) -> Money { Money(cents: lhs.cents - rhs.cents, currency: lhs.currency) }
}
