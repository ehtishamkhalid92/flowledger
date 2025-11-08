//
//  AccountDetailScreen.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI

struct AccountDetailScreen: View {
    let account: AccountVM

    // Lookups
    @State private var accountById: [AccountID: Account] = [:]
    @State private var categoryById: [CategoryID: Category] = [:]

    // Data
    @State private var allTx: [TxVM] = []
    @State private var showClearedOnly = false

    private var txForAccount: [TxVM] {
        allTx
            .filter { $0.accountName == account.name && (!showClearedOnly || $0.isCleared) }
            .sorted(by: { $0.date > $1.date })
    }

    private var inflow: Int  { txForAccount.filter { $0.kind == .income  }.map(\.amountCents).reduce(0, +) }
    private var outflow: Int { txForAccount.filter { $0.kind == .expense }.map(\.amountCents).reduce(0, +) }

    var body: some View {
        List {
            // Header card
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

            // Toggle row
            Section {
                Toggle(isOn: $showClearedOnly) {
                    Label("Show cleared only", systemImage: showClearedOnly ? "checkmark.circle" : "circle")
                }
            }

            // Recent transactions
            Section("Recent") {
                if txForAccount.isEmpty {
                    Text("No transactions yet").foregroundStyle(.secondary)
                } else {
                    ForEach(txForAccount) { tx in
                        TransactionRow(vm: tx)
                    }
                }
            }

            // Goals placeholder
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
        .task {
            await loadLookups()
            await reload()
        }
        .onChange(of: showClearedOnly) { _ in } // keeps state-driven refresh local
    }

    // MARK: Data

    private func loadLookups() async {
        do {
            let accs = try await DI.listAccounts.execute()
            accountById = Dictionary(uniqueKeysWithValues: accs.map { ($0.id, $0) })

            let cats = try await DI.categoryRepo.list(kind: nil)
            categoryById = Dictionary(uniqueKeysWithValues: cats.map { ($0.id, $0) })
        } catch {
            print("AccountDetail lookups failed: \(error)")
        }
    }

    private func reload() async {
        do {
            var q = TxQuery()
            q.accountId = account.id
            let domainItems = try await DI.txRepo.list(query: q)
            allTx = domainItems.map { mapTransactionToVM($0, accountsById: accountById, categoriesById: categoryById) }
        } catch {
            print("AccountDetail list failed: \(error)")
        }
    }
}
