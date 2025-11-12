//
//  MoneyText.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI

struct MoneyText: View {
    let cents: Int
    let currencyCode: String

    init(_ cents: Int, currencyCode: String = "CHF") {
        self.cents = cents
        self.currencyCode = currencyCode
    }

    // Localized, per-call formatter so currencyCode is respected.
    private static func string(for cents: Int, currencyCode: String) -> String {
        let amount = Double(cents) / 100.0
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.maximumFractionDigits = 2
        f.currencyCode = currencyCode
        return f.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }

    // Utility used by charts/labels outside of a View context.
    static func formatCents(_ cents: Int, currencyCode: String = "CHF") -> String {
        string(for: cents, currencyCode: currencyCode)
    }

    var body: some View {
        Text(Self.string(for: cents, currencyCode: currencyCode))
            .fontWeight(.semibold)
    }
}
