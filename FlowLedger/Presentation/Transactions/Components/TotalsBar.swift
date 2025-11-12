//
//  TotalsBar.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 12.11.2025.
//

import SwiftUI

struct TotalsBar: View {
    let incomeCents: Int
    let expenseCents: Int
    let netCents: Int

    var body: some View {
        HStack(spacing: 12) {
            pill(title: "Income", cents: incomeCents, tint: .green)
            pill(title: "Expense", cents: expenseCents, tint: .red)
            pill(title: "Net", cents: netCents, tint: netCents >= 0 ? .green : .red)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 6)
    }

    private func pill(title: String, cents: Int, tint: Color) -> some View {
        HStack(spacing: 6) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            MoneyText(cents).font(.subheadline).bold()
                .foregroundStyle(tint)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
