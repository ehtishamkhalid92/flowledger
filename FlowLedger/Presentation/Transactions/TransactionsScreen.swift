//
//  TransactionsScreen.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI

// MARK: - ViewModels (UI-only list for now; saving goes through domain)

struct TxVM: Identifiable, Hashable {
    enum Kind: String, CaseIterable { case expense, income, transfer }
    let id: String
    let kind: Kind
    let amountCents: Int
    let accountName: String
    let categoryName: String?
    let icon: String
    let note: String?
    let date: Date
    let isCleared: Bool

    var signedAmount: Int {
        switch kind {
        case .expense:  return -abs(amountCents)
        case .income:   return  abs(amountCents)
        case .transfer: return  amountCents
        }
    }
}

struct TxFilterState: Equatable {
    var month: Date = .now
    var account: String? = nil
    var category: String? = nil
    var search: String = ""
    var showClearedOnly: Bool = false
}

// MARK: - Screen

struct TransactionsScreen: View {
    @State private var filter = TxFilterState()
    @State private var showAddSheet = false

    // Loaded from domain (names + lookup maps)
    @State private var accounts: [String] = []
    @State private var categories: [String] = []
    @State private var accountIndex: [String: AccountID] = [:]
    @State private var categoryIndex: [String: CategoryID] = [:]

    // UI list still local for now; domain saving is wired
    @State private var txs: [TxVM] = [
        .init(id: "t1", kind: .expense, amountCents: 174_400, accountName: "Current", categoryName: "Housing", icon: "house.fill", note: "Rent Nov", date: .now.addingTimeInterval(TimeInterval(-86400*5)), isCleared: true),
        .init(id: "t2", kind: .expense, amountCents: 49_785,  accountName: "Current", categoryName: "Car",     icon: "car.fill", note: "Car EMI", date: .now.addingTimeInterval(TimeInterval(-86400*4)), isCleared: true),
        .init(id: "t3", kind: .expense, amountCents: 55_850,  accountName: "Current", categoryName: "Insurance", icon: "stethoscope", note: "Health", date: .now.addingTimeInterval(TimeInterval(-86400*3)), isCleared: false),
        .init(id: "t4", kind: .income,  amountCents: 685_900, accountName: "Current", categoryName: "Salary", icon: "briefcase.fill", note: "Salary Nov", date: .now.addingTimeInterval(TimeInterval(-86400*6)), isCleared: true),
        .init(id: "t5", kind: .expense, amountCents: 20_000,  accountName: "Current", categoryName: "Food", icon: "fork.knife", note: "Groceries", date: .now.addingTimeInterval(TimeInterval(-86400*1)), isCleared: false),
        .init(id: "t6", kind: .transfer, amountCents: 70_000, accountName: "Current", categoryName: nil, icon: "arrow.left.arrow.right", note: "To Savings (EF)", date: .now, isCleared: true)
    ]

    var body: some View {
        VStack(spacing: 0) {
            FilterBar(
                month: $filter.month,
                accounts: accounts, selectedAccount: $filter.account,
                categories: categories, selectedCategory: $filter.category,
                search: $filter.search,
                showClearedOnly: $filter.showClearedOnly
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            List {
                ForEach(sectioned(txs: filtered(txs: txs)), id: \.monthId) { section in
                    Section(section.monthTitle) {
                        ForEach(section.items) { item in
                            TransactionRow(vm: item)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle(String(localized: "tab.transactions"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddTransactionSheet(
                accounts: accounts,
                categories: categories,
                onSave: { newItem in
                    Task {
                        await saveViaDomain(newItem)
                        txs.insert(newItem, at: 0) // optimistic UI
                    }
                }
            )
            .presentationDetents([.medium, .large])
        }
        .task {
            await loadFilters()
        }
    }

    // MARK: Domain wiring

    private func loadFilters() async {
        do {
            let accs = try await DI.listAccounts.execute()
            accounts = accs.map(\.name)
            accountIndex = Dictionary(uniqueKeysWithValues: accs.map { ($0.name, $0.id) })

            let cats = try await DI.categoryRepo.list(kind: nil)
            categories = cats.map(\.name)
            categoryIndex = Dictionary(uniqueKeysWithValues: cats.map { ($0.name, $0.id) })
        } catch {
            print("Load filters failed: \(error)")
        }
    }

    private func saveViaDomain(_ vm: TxVM) async {
        guard let accountId = accountIndex[vm.accountName] else { return }
        switch vm.kind {
        case .expense:
            guard let catName = vm.categoryName, let catId = categoryIndex[catName] else { return }
            do {
                try await DI.addExpense.execute(
                    amount: Money(cents: abs(vm.amountCents)),
                    accountId: accountId,
                    categoryId: catId,
                    note: vm.note,
                    date: vm.date,
                    cleared: vm.isCleared
                )
            } catch { print("Add expense failed: \(error)") }

        case .income:
            guard let catName = vm.categoryName, let catId = categoryIndex[catName] else { return }
            do {
                try await DI.addIncome.execute(
                    amount: Money(cents: abs(vm.amountCents)),
                    accountId: accountId,
                    categoryId: catId,
                    note: vm.note,
                    date: vm.date,
                    cleared: vm.isCleared
                )
            } catch { print("Add income failed: \(error)") }

        case .transfer:
            // To-account picker will be added in Step 10.1, then call DI.transfer here.
            break
        }
    }

    // MARK: Filtering & sectioning

    private func filtered(txs: [TxVM]) -> [TxVM] {
        let (start, end) = monthBounds(for: filter.month)
        return txs.filter { t in
            (t.date >= start && t.date < end)
            && (filter.account == nil || t.accountName == filter.account)
            && (filter.category == nil || t.categoryName == filter.category)
            && (filter.search.isEmpty || t.note?.localizedCaseInsensitiveContains(filter.search) == true)
            && (!filter.showClearedOnly || t.isCleared)
        }
        .sorted(by: { $0.date > $1.date })
    }

    private struct Sectioned { let monthId: String; let monthTitle: String; let items: [TxVM] }

    private func sectioned(txs: [TxVM]) -> [Sectioned] {
        let df = DateFormatter()
        df.dateFormat = "LLLL yyyy"
        let groups = Dictionary(grouping: txs) { Calendar.current.dateInterval(of: .month, for: $0.date) ?? DateInterval(start: .distantPast, end: .distantFuture) }
        return groups.keys.sorted(by: { $0.start > $1.start }).map { interval in
            let key = String(df.string(from: interval.start).prefix(20))
            return Sectioned(monthId: key, monthTitle: key, items: groups[interval]!.sorted(by: { $0.date > $1.date }))
        }
    }

    private func monthBounds(for date: Date) -> (Date, Date) {
        let cal = Calendar.current
        let start = cal.date(from: cal.dateComponents([.year, .month], from: date))!
        let end = cal.date(byAdding: DateComponents(month: 1), to: start)!
        return (start, end)
    }
}
