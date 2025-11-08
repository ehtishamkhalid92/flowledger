//
//  ReportsScreen.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI

struct ReportsScreen: View {
    @State private var month: Date = .now
    @State private var shareURL: URL? = nil
    @State private var showingShare = false

    // Lookups
    @State private var accountById: [AccountID: Account] = [:]
    @State private var categoryById: [CategoryID: Category] = [:]

    // Data
    @State private var txs: [TxVM] = []

    private var monthTx: [TxVM] {
        let (start, end) = monthBounds(for: month)
        return txs.filter { $0.date >= start && $0.date < end }
    }
    private var income: Int  { monthTx.filter { $0.kind == .income  }.map(\.amountCents).reduce(0,+) }
    private var expense: Int { monthTx.filter { $0.kind == .expense }.map(\.amountCents).reduce(0,+) }
    private var net: Int { income - expense }

    private var topCategories: [(String, Int)] {
        let items = monthTx.filter { $0.kind == .expense }
        let grouped = Dictionary(grouping: items, by: { $0.categoryName ?? "Other" })
        return grouped
            .map { (k, v) in (k, v.map(\.amountCents).reduce(0,+)) }
            .sorted(by: { $0.1 > $1.1 })
            .prefix(5)
            .map { ($0.0, $0.1) }
    }

    var body: some View {
        List {
            Section {
                HStack {
                    MonthPicker(date: $month)
                    Spacer()
                    Button {
                        exportPDF()
                    } label: {
                        Label("Export PDF", systemImage: "square.and.arrow.up")
                    }
                }
            }

            Section("Summary") {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Income").font(.caption).foregroundStyle(.secondary)
                        MoneyText(income).foregroundStyle(.green)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Expenses").font(.caption).foregroundStyle(.secondary)
                        MoneyText(expense).foregroundStyle(.red)
                    }
                }
                HStack {
                    Text("Net").font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    MoneyText(net).font(.title3).bold()
                        .foregroundStyle(net >= 0 ? .green : .red)
                }
            }

            Section("Top Categories") {
                if topCategories.isEmpty {
                    Text("No expenses this month").foregroundStyle(.secondary)
                } else {
                    ForEach(topCategories, id: \.0) { cat, cents in
                        HStack {
                            Text(cat)
                            Spacer()
                            MoneyText(cents)
                        }
                    }
                }
            }

            Section("Notes") {
                Text("SwiftData-backed report for the selected month.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Reports")
        .sheet(isPresented: $showingShare) {
            if let shareURL {
                ShareLink(item: shareURL) { Label("Share Report", systemImage: "square.and.arrow.up") }
                    .padding()
            } else {
                Text("Failed to create report").padding()
            }
        }
        .task {
            await loadLookups()
            await reload()
        }
        .onChange(of: month) { _ in
            Task { await reload() }
        }
    }

    // MARK: Data

    private func loadLookups() async {
        do {
            let accs = try await DI.listAccounts.execute()
            accountById = Dictionary(uniqueKeysWithValues: accs.map { ($0.id, $0) })

            let cats = try await DI.categoryRepo.list(kind: nil)
            categoryById = Dictionary(uniqueKeysWithValues: cats.map { ($0.id, $0) })
        } catch {
            print("Reports lookups failed: \(error)")
        }
    }

    private func reload() async {
        do {
            var q = TxQuery()
            q.month = month
            let domainItems = try await DI.txRepo.list(query: q)
            txs = domainItems.map { mapTransactionToVM($0, accountsById: accountById, categoriesById: categoryById) }
        } catch {
            print("Reports load failed: \(error)")
        }
    }

    // MARK: PDF

    private func exportPDF() {
        let monthTitle = month.formatted(.dateTime.month().year())
        let blocks: [PDFExporter.ReportBlock] = [
            .init(title: "Summary \(monthTitle)", lines: [
                "Income: \(formatCHF(income))",
                "Expenses: \(formatCHF(expense))",
                "Net: \(formatCHF(net))"
            ]),
            .init(title: "Top Categories", lines: topCategories.map { "\($0.0): \(formatCHF($0.1))" })
        ]

        do {
            let url = try PDFExporter.makePDFFile(
                fileName: "FlowLedger-\(monthTitle)",
                title: "FlowLedger Monthly Report — \(monthTitle)",
                blocks: blocks
            )
            shareURL = url
            showingShare = true
        } catch {
            shareURL = nil
            showingShare = true
        }
    }

    // MARK: Helpers

    private func formatCHF(_ cents: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "CHF"
        return f.string(from: NSNumber(value: Double(cents) / 100.0)) ?? "CHF 0.00"
    }

    private func monthBounds(for date: Date) -> (Date, Date) {
        let cal = Calendar.current
        let start = cal.date(from: cal.dateComponents([.year, .month], from: date))!
        let end = cal.date(byAdding: DateComponents(month: 1), to: start)!
        return (start, end)
    }
}
