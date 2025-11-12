//
//  ReportsScreen.swift
//  FlowLedger
//

import SwiftUI

struct ReportsScreen: View {
    // Persist month selection
    @AppStorage("reports.monthISO") private var storedMonthISO: String = ""

    @State private var month: Date = Date()
    @State private var items: [Transaction] = []

    // lookups for category names
    @State private var categoryById: [CategoryID: Category] = [:]

    // derived
    @State private var incomeCents: Int = 0
    @State private var expenseCents: Int = 0
    @State private var netCents: Int = 0
    @State private var topCategories: [(name: String, cents: Int)] = []

    // export
    @State private var isExporting = false
    @State private var exportURL: URL?

    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Button {
                    month = Calendar.current.date(byAdding: .month, value: -1, to: month)!
                    Task { await reload() }
                } label: { Image(systemName: "chevron.left") }

                Spacer()

                Text(monthTitle(month))
                    .font(.largeTitle).bold()

                Spacer()

                Button {
                    month = Calendar.current.date(byAdding: .month, value: +1, to: month)!
                    Task { await reload() }
                } label: { Image(systemName: "chevron.right") }
            }
            .padding(.horizontal)

            // Summary card
            SummaryCard(incomeCents: incomeCents, expenseCents: expenseCents, netCents: netCents)

            // Donut
            if expenseCents > 0 {
                DonutCard(
                    slices: topCategories.map { DonutChart.Slice(label: $0.name, value: Double($0.cents)) }
                )
            }

            // Top categories list
            GroupBox {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Top Categories").font(.headline)
                    if topCategories.isEmpty {
                        Text("No expenses this month").foregroundStyle(.secondary)
                    } else {
                        ForEach(topCategories, id: \.name) { row in   // <-- no Binding here
                            HStack {
                                Text(row.name)
                                Spacer()
                                MoneyText(row.cents)                    // <-- correct init
                                    .foregroundStyle(.red)
                                    .font(.headline)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)

            Spacer(minLength: 8)
        }
        .navigationTitle("Reports")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await exportPDF() }
                } label: {
                    Label("Export PDF", systemImage: "square.and.arrow.up")
                }
            }
        }
        .task {
            restoreMonth()
            await reload()
        }
        .onChange(of: month) { _, _ in persistMonth() }
        .sheet(isPresented: $isExporting, onDismiss: { exportURL = nil }) {
            if let url = exportURL {
                ShareSheet(activityItems: [url])
            }
        }
    }

    // MARK: Load & compute

    private func reload() async {
        do {
            // load categories once for name lookup
            let cats = try await DI.categoryRepo.list(kind: nil)
            categoryById = Dictionary(uniqueKeysWithValues: cats.map { ($0.id, $0) })

            var q = TxQuery()
            q.month = month
            items = try await DI.txRepo.list(query: q)

            // income / expense / net
            incomeCents = items
                .filter { $0.kind == .income }
                .reduce(0) { $0 + $1.amount.cents }
            expenseCents = items
                .filter { $0.kind == .expense }
                .reduce(0) { $0 + $1.amount.cents }
            netCents = incomeCents - expenseCents

            // top categories (expenses only)
            let grouped = Dictionary(grouping: items.filter { $0.kind == .expense }) {
                $0.categoryId ?? "UNCATEGORIZED"
            }
            let sums: [(name: String, cents: Int)] = grouped.map { (key, txs) in
                let total = txs.reduce(0) { $0 + $1.amount.cents }
                let name = categoryById[key]?.name ?? "Other"
                return (name: name, cents: total)
            }
            topCategories = sums.sorted(by: { $0.cents > $1.cents }).prefix(6).map { $0 }
        } catch {
            print("Reports load failed: \(error)")
            items = []
            incomeCents = 0; expenseCents = 0; netCents = 0; topCategories = []
        }
    }

    // MARK: Export

    private func exportPDF() async {
        let view = ReportsPDFView(
            monthTitle: monthTitle(month),
            incomeCents: incomeCents,
            expenseCents: expenseCents,
            netCents: netCents,
            categories: topCategories
        )
        do {
            let url = try SimplePDFExporter.export(
                view: AnyView(view),
                fileName: "FlowLedger_\(monthISO(month)).pdf"
            )
            exportURL = url
            isExporting = true
        } catch {
            print("PDF export failed: \(error)")
        }
    }

    // MARK: Utils

    private func monthTitle(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f.string(from: d)
    }

    private func monthISO(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        return f.string(from: d)
    }

    private func persistMonth() {
        storedMonthISO = monthISO(month)
    }

    private func restoreMonth() {
        if !storedMonthISO.isEmpty {
            let f = DateFormatter(); f.dateFormat = "yyyy-MM"
            if let d = f.date(from: storedMonthISO) { month = d }
        }
    }
}

// MARK: - UI Pieces

private struct SummaryCard: View {
    let incomeCents: Int
    let expenseCents: Int
    let netCents: Int

    var body: some View {
        HStack(spacing: 12) {
            StatPill(title: "Income", cents: incomeCents, color: .green)
            StatPill(title: "Expense", cents: expenseCents, color: .red)
            StatPill(title: "Net", cents: netCents, color: netCents >= 0 ? .green : .red)
        }
        .padding(.horizontal)
    }

    private struct StatPill: View {
        let title: String
        let cents: Int
        let color: Color

        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.caption).foregroundStyle(.secondary)
                MoneyText(cents)                    // <-- correct init
                    .font(.title3).bold()
                    .foregroundStyle(color)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(.secondary.opacity(0.15), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

private struct DonutCard: View {
    // Use the SAME slice type as DonutChart to avoid mismatches
    let slices: [DonutChart.Slice]

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text("Spending by Category").font(.headline)
                DonutChart(slices: slices)
                    .frame(height: 180)

                // Legend
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(slices.enumerated()), id: \.offset) { idx, s in
                        HStack(spacing: 8) {
                            Circle().fill(DonutChart.color(for: idx)).frame(width: 10, height: 10)
                            Text(s.label)
                            Spacer()
                            Text(MoneyText.formatCents(Int(s.value))).monospacedDigit()
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
