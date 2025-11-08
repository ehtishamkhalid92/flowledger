//
//  AccountDetailScreen.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI

struct AccountDetailScreen: View {
    let account: AccountVM

    @State private var allTx: [TxVM] = [
        .init(id: "t1", kind: .income,  amountCents: 685_900, accountName: "Current", categoryName: "Salary", icon: "briefcase.fill", note: "Salary Nov", date: .now.addingTimeInterval(TimeInterval(-86400*6)), isCleared: true),
        .init(id: "t2", kind: .expense, amountCents: 174_400, accountName: "Current", categoryName: "Housing", icon: "house.fill", note: "Rent", date: .now.addingTimeInterval(TimeInterval(-86400*5)), isCleared: true),
        .init(id: "t3", kind: .expense, amountCents: 49_785,  accountName: "Current", categoryName: "Car", icon: "car.fill", note: "EMI", date: .now.addingTimeInterval(TimeInterval(-86400*4)), isCleared: true),
        .init(id: "t4", kind: .expense, amountCents: 20_000,  accountName: "Current", categoryName: "Food", icon: "fork.knife", note: "Groceries", date: .now.addingTimeInterval(TimeInterval(-86400*1)), isCleared: false),
        .init(id: "t5", kind: .transfer, amountCents: 70_000, accountName: "Current", categoryName: nil, icon: "arrow.left.arrow.right", note: "To Savings (EF)", date: .now, isCleared: true),

        .init(id: "s1", kind: .transfer, amountCents: 70_000, accountName: "Savings", categoryName: nil, icon: "arrow.left.arrow.right", note: "From Current (EF)", date: .now, isCleared: true),
        .init(id: "cc1", kind: .expense, amountCents: 12_999, accountName: "Credit Card", categoryName: "Subscriptions", icon: "rectangle.stack.person.crop", note: "Tesla", date: .now.addingTimeInterval(TimeInterval(-86400*2)), isCleared: true)
    ]

    @State private var showClearedOnly = false

    private var txForAccount: [TxVM] {
        allTx
            .filter { $0.accountName == account.name && (!showClearedOnly || $0.isCleared) }
            .sorted(by: { $0.date > $1.date })
    }

    private var inflow: Int  { txForAccount.filter { $0.kind == .income  }.map(\.amountCents).reduce(0,+) }
    private var outflow: Int { txForAccount.filter { $0.kind == .expense }.map(\.amountCents).reduce(0,+) }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(account.name).font(.title2).bold()
                        Spacer()
                        Image(systemName: account.icon)
                    }
                    HStack {
                        Text("Balance").font(.subheadline).foregroundStyle(.secondary)
                        Spacer()
                        MoneyText(account.balanceCents).font(.title3).bold()
                    }
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Inflow").font(.caption).foregroundStyle(.secondary)
                            MoneyText(inflow).foregroundStyle(.green)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Outflow").font(.caption).foregroundStyle(.secondary)
                            MoneyText(outflow).foregroundStyle(.red)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            Section {
                Toggle(isOn: $showClearedOnly) {
                    Label("Show cleared only", systemImage: showClearedOnly ? "checkmark.circle" : "circle")
                }
            }

            Section("Recent") {
                if txForAccount.isEmpty {
                    Text("No transactions yet").foregroundStyle(.secondary)
                } else {
                    ForEach(txForAccount) { tx in
                        TransactionRow(vm: tx)
                    }
                }
            }

            Section("Goals (placeholder)") {
                HStack {
                    Text("Emergency Fund").foregroundStyle(.secondary)
                    Spacer()
                    Text("CHF 700 / mo").font(.footnote)
                }
                HStack {
                    Text("Kids Fund").foregroundStyle(.secondary)
                    Spacer()
                    Text("CHF 120 / mo").font(.footnote)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(account.name)
    }
}
