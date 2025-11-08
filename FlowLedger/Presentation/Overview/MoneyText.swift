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

    private static let fmt: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.maximumFractionDigits = 2
        f.currencyCode = "CHF" // default; override by formatting if needed
        return f
    }()

    var body: some View {
        let amount = Double(cents) / 100.0
        let formatted = MoneyText.fmt.string(from: NSNumber(value: amount)) ?? "\(amount)"
        Text(formatted)
            .fontWeight(.semibold)
    }
}
