//
//  AccountsScreen.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI

struct AccountsScreen: View {
    @State private var accounts: [AccountVM] = [
        .init(id: "a1", name: "Current",     kind: .current,    balanceCents: 285_000, deltaCents: 12_000),
        .init(id: "a2", name: "Savings",     kind: .savings,    balanceCents: 470_000, deltaCents: 0),
        .init(id: "a3", name: "Credit Card", kind: .creditCard, balanceCents: -30_000, deltaCents: -5_000),
        .init(id: "a4", name: "Cash",        kind: .cash,       balanceCents: 1_500,   deltaCents: 0)
    ]

    private var totalNetCents: Int { accounts.map(\.balanceCents).reduce(0,+) }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                SectionCard {
                    HStack {
                        AppTheme.section("Total Net Worth")
                        Spacer()
                        MoneyText(totalNetCents).font(.title3).bold()
                    }
                }

                SectionCard {
                    AppTheme.section("Accounts")
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(accounts) { acc in
                            NavigationLink {
                                AccountDetailScreen(account: acc)
                            } label: {
                                AccountCard(vm: acc)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(AppTheme.bg.ignoresSafeArea())
        .scrollIndicators(.hidden)
        .navigationTitle("Accounts")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Add Account", systemImage: "plus") {}
                    Button("Reorder", systemImage: "arrow.up.arrow.down") {}
                } label: { Image(systemName: "ellipsis.circle") }
            }
        }
    }
}
