//
//  OverviewScreen.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI
import Charts

struct OverviewScreen: View {
    // Domain-driven data
    @State private var accounts: [AccountVM] = []
    @State private var incomeCents: Int = 0
    @State private var expenseCents: Int = 0
    private var thisMonthNet: Int { incomeCents - expenseCents }

    // Placeholder chart data (until SwiftData wired)
    @State private var catSpending: [(category: String, cents: Int)] = [
        ("Housing", 174_400),
        ("Car", 56_700),
        ("Insurance", 55_850),
        ("Food", 20_000),
        ("Charging", 7_000)
    ]

    @State private var trend: [(String, Int, Int)] = [
        ("Jun", 685_900, 520_000),
        ("Jul", 685_900, 544_000),
        ("Aug", 685_900, 556_000),
        ("Sep", 685_900, 560_000),
        ("Oct", 685_900, 575_000),
        ("Nov", 685_900, 567_161)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // Accounts grid
                SectionCard {
                    AppTheme.section("Accounts")
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(accounts) { acc in
                            AccountCard(vm: acc)
                        }
                    }
                }

                // Quick stats
                SectionCard {
                    AppTheme.section("This Month")
                    HStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Income").font(.subheadline).foregroundStyle(.secondary)
                            MoneyText(incomeCents).foregroundStyle(.green)
                        }
                        Divider().frame(height: 44)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Expenses").font(.subheadline).foregroundStyle(.secondary)
                            MoneyText(expenseCents).foregroundStyle(.red)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Net").font(.subheadline).foregroundStyle(.secondary)
                            MoneyText(thisMonthNet).font(.title3).bold()
                                .foregroundStyle(thisMonthNet >= 0 ? .green : .red)
                        }
                    }
                }

                // Donut: spending by category (placeholder)
                SectionCard {
                    AppTheme.section("Spending by Category")
                    Chart(catSpending, id: \.category) { item in
                        SectorMark(
                            angle: .value("Amount", item.cents),
                            innerRadius: .ratio(0.6)
                        )
                        .foregroundStyle(by: .value("Category", item.category))
                    }
                    .frame(height: 200)
                }

                // Bars: income vs expense (placeholder)
                SectionCard {
                    AppTheme.section("Income vs Expense")
                    Chart {
                        ForEach(trend, id: \.0) { m in
                            BarMark(x: .value("Month", m.0), y: .value("Income", m.1))
                                .foregroundStyle(.green.opacity(0.7))
                            BarMark(x: .value("Month", m.0), y: .value("Expense", m.2))
                                .foregroundStyle(.red.opacity(0.7))
                        }
                    }
                    .frame(height: 220)
                }
            }
            .padding(16)
        }
        .background(AppTheme.bg.ignoresSafeArea())
        .navigationTitle(String(localized: "tab.overview"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Add Expense", systemImage: "minus.circle.fill") {}
                    Button("Add Income", systemImage: "plus.circle.fill") {}
                    Button("Transfer", systemImage: "arrow.left.arrow.right.circle.fill") {}
                } label: { Image(systemName: "plus.circle.fill") }
            }
        }
        .task {
            do {
                let list = try await DI.listAccounts.execute()
                accounts = list.map(toVM)

                let summary = try await DI.monthSummary.execute(month: .now)
                incomeCents  = summary.income.cents
                expenseCents = summary.expense.cents
            } catch {
                print("Overview load failed: \(error)")
            }
        }
    }
}
