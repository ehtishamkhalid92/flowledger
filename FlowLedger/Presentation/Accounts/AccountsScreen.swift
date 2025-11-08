//
//  AccountsScreen.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//
import SwiftUI

struct AccountsScreen: View {
    @State private var accounts: [AccountVM] = []

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
        .navigationTitle("Accounts")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Add Account", systemImage: "plus") {}
                    Button("Reorder", systemImage: "arrow.up.arrow.down") {}
                } label: { Image(systemName: "ellipsis.circle") }
            }
        }
        .task {
            do {
                let list = try await DI.listAccounts.execute()
                accounts = list.map(mapAccountToVM)  // ← local mapper below
            } catch {
                print("List accounts failed: \(error)")
            }
        }
    }
}
