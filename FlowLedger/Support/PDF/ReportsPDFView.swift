//
//  ReportsPDFView.swift
//  FlowLedger
//

import SwiftUI

struct ReportsPDFView: View {
    let monthTitle: String
    let incomeCents: Int
    let expenseCents: Int
    let netCents: Int
    let categories: [(name: String, cents: Int)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("FlowLedger Report").font(.title).bold()
            Text(monthTitle).font(.headline)
            Divider()

            HStack(spacing: 24) {
                VStack(alignment: .leading) {
                    Text("Income").font(.caption).foregroundStyle(.secondary)
                    MoneyText(incomeCents, currencyCode: "CHF")
                        .font(.title3)
                        .foregroundStyle(.green)
                }
                VStack(alignment: .leading) {
                    Text("Expense").font(.caption).foregroundStyle(.secondary)
                    MoneyText(expenseCents, currencyCode: "CHF")
                        .font(.title3)
                        .foregroundStyle(.red)
                }
                VStack(alignment: .leading) {
                    Text("Net").font(.caption).foregroundStyle(.secondary)
                    MoneyText(netCents, currencyCode: "CHF")
                        .font(.title3)
                        .foregroundStyle(netCents >= 0 ? .green : .red)
                }
            }

            Divider()
            Text("Top Categories").font(.headline)

            if categories.isEmpty {
                Text("No expenses this month").foregroundStyle(.secondary)
            } else {
                ForEach(categories, id: \.name) { row in
                    HStack {
                        Text(row.name)
                        Spacer()
                        MoneyText(row.cents, currencyCode: "CHF")
                    }
                }
            }
        }
        .padding()
    }
}
