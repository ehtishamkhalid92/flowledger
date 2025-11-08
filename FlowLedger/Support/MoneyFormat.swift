//
//  MoneyFormat.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import Foundation

enum MoneyFormat {
    /// Formats cents as CHF by default (e.g. 470000 -> "CHF 4’700.00")
    static func chf(_ cents: Int) -> String {
        let amount = Double(cents) / 100.0
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "CHF"          // you can later bind this to @AppStorage(AppSettings.Keys.currency)
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 2
        // Some locales use the apostrophe for thousands (’). System locale will decide.
        return f.string(from: NSNumber(value: amount)) ?? "CHF \(String(format: "%.2f", amount))"
    }
}

extension Money {
    func chfString() -> String { MoneyFormat.chf(cents) }
}
