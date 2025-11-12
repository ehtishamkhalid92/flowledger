//
//  TransactionsScreen.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI

struct TransactionsScreen: View {
    // Persisted filter bits
    @AppStorage("tx.filter.account") private var storedAccount: String = ""
    @AppStorage("tx.filter.category") private var storedCategory: String = ""
    @AppStorage("tx.filter.search") private var storedSearch: String = ""
    @AppStorage("tx.filter.clearedOnly") private var storedClearedOnly: Bool = false
    @AppStorage("tx.filter.month") private var storedMonthISO: String = ""   // ISO yyyy-MM

    @State private var filter = TxFilterState()
    @State private var showAddSheet = false

    // EDIT / DELETE UI
    @State private var editing: TxVM? = nil
    @State private var pendingDelete: TxVM? = nil

    // Lookups from domain
    @State private var accounts: [String] = []
    @State private var categories: [String] = []
    @State private var accountByName: [String: AccountID] = [:]
    @State private var accountById: [AccountID: Account] = [:]
    @State private var categoryByName: [String: CategoryID] = [:]
    @State private var categoryById: [CategoryID: Category] = [:]

    // Repo-backed list (we still apply UI-side filters)
    @State private var txs: [TxVM] = []

    // Totals for current filtered dataset
    @State private var incomeCents = 0
    @State private var expenseCents = 0
    @State private var netCents = 0

    var body: some View {
        VStack(spacing: 0) {
            // Filters
            FilterBar(
                month: $filter.month,
                accounts: accounts, selectedAccount: $filter.account,
                categories: categories, selectedCategory: $filter.category,
                search: $filter.search,
                showClearedOnly: $filter.showClearedOnly,
                onReload: { Task { await reloadFromRepo() } },
                onClearFilters: { persistFilters() }
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            // Totals
            TotalsBar(incomeCents: incomeCents, expenseCents: expenseCents, netCents: netCents)

            // List
            List {
                ForEach(sectioned(txs: filtered(txs: txs)), id: \.monthId) { section in
                    Section(section.monthTitle) {
                        ForEach(section.items) { item in
                            TransactionRow(vm: item)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editing = item
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {   // was true
                                    Button {
                                        Task {
                                            await toggleCleared(item)
                                            await reloadFromRepo()
                                        }
                                    } label: {
                                        Label(item.isCleared ? "Unclear" : "Clear",
                                              systemImage: item.isCleared ? "xmark.circle" : "checkmark.circle")
                                    }.tint(.blue)

                                    Button(role: .destructive) {
                                        pendingDelete = item
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle(String(localized: "tab.transactions"))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    clearFilters()
                } label: {
                    Label("Clear", systemImage: "line.3.horizontal.decrease.circle")
                }
                .help("Clear all filters")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        // ADD
        .sheet(isPresented: $showAddSheet) {
            AddTransactionSheet(
                accounts: accounts,
                categories: categories,
                onSave: { newItem in
                    Task {
                        await saveViaDomain(newItem)
                        await reloadFromRepo()
                    }
                }
            )
            .presentationDetents([.medium, .large])
        }
        // EDIT (prefilled)
        .sheet(item: $editing, onDismiss: {
            editing = nil
        }) { tx in
            AddTransactionSheet(
                accounts: accounts,
                categories: categories,
                preset: .init(
                    kind: tx.kind,
                    amountCents: abs(tx.amountCents),
                    accountName: tx.accountName,
                    toAccountName: tx.toAccountName,
                    categoryName: tx.categoryName,
                    note: tx.note ?? "",
                    date: tx.date,
                    cleared: tx.isCleared
                ),
                onSave: { updated in
                    Task {
                        // simplest: delete & recreate with new values
                        await deleteTx(tx)
                        await saveViaDomain(updated)
                        await reloadFromRepo()
                    }
                }
            )
            .presentationDetents([.medium, .large])
        }
        // DELETE confirm
        // DELETE confirm (replace your .confirmationDialog with this)
        .alert("Delete transaction?", isPresented: Binding(
            get: { pendingDelete != nil },
            set: { if !$0 { pendingDelete = nil } }
        ), presenting: pendingDelete) { tx in
            Button("Delete", role: .destructive) {
                Task {
                    await deleteTx(tx)
                    pendingDelete = nil
                    await reloadFromRepo()
                }
            }
            Button("Cancel", role: .cancel) {
                pendingDelete = nil
            }
        } message: { _ in
            Text("This cannot be undone.")
        }
        .task {
            restoreFilters()
            await loadLookups()
            await reloadFromRepo()
            recalcTotals()
        }
        .onChange(of: filter.month) { _, _ in
            Task { await reloadFromRepo(); persistFilters(); recalcTotals() }
        }
        .onChange(of: filter.account) { _, _ in persistFilters(); recalcTotals() }
        .onChange(of: filter.category) { _, _ in persistFilters(); recalcTotals() }
        .onChange(of: filter.search) { _, _ in persistFilters(); recalcTotals() }
        .onChange(of: filter.showClearedOnly) { _, _ in persistFilters(); recalcTotals() }
        .onChange(of: txs) { _, _ in recalcTotals() }
    }

    // MARK: Domain wiring

    private func loadLookups() async {
        do {
            // Accounts
            let accs = try await DI.listAccounts.execute()
            accounts = accs.map(\.name)
            accountByName = Dictionary(uniqueKeysWithValues: accs.map { ($0.name, $0.id) })
            accountById   = Dictionary(uniqueKeysWithValues: accs.map { ($0.id, $0) })

            // Categories (typed nil so the correct overload is chosen)
            let cats = try await DI.categoryRepo.list(kind: nil as CategoryKind?)
            categories = cats.map(\.name)
            categoryByName = Dictionary(uniqueKeysWithValues: cats.map { ($0.name, $0.id) })
            categoryById   = Dictionary(uniqueKeysWithValues: cats.map { ($0.id, $0) })
        } catch {
            print("Load lookups failed: \(error)")
        }
    }

    private func reloadFromRepo() async {
        do {
            var q = TxQuery()
            q.month = filter.month
            let domainItems = try await DI.txRepo.list(query: q)
            txs = domainItems
                .map { mapToVM($0) }
                .sorted(by: { $0.date > $1.date })
        } catch {
            print("List tx failed: \(error)")
        }
    }

    private func saveViaDomain(_ vm: TxVM) async {
        guard let fromId = accountByName[vm.accountName] else { return }
        switch vm.kind {
        case .expense:
            guard let catName = vm.categoryName, let catId = categoryByName[catName] else { return }
            do {
                try await DI.addExpense.execute(
                    amount: Money(cents: abs(vm.amountCents)),
                    accountId: fromId,
                    categoryId: catId,
                    note: vm.note,
                    date: vm.date,
                    cleared: vm.isCleared
                )
            } catch { print("Add expense failed: \(error)") }

        case .income:
            guard let catName = vm.categoryName, let catId = categoryByName[catName] else { return }
            do {
                try await DI.addIncome.execute(
                    amount: Money(cents: abs(vm.amountCents)),
                    accountId: fromId,
                    categoryId: catId,
                    note: vm.note,
                    date: vm.date,
                    cleared: vm.isCleared
                )
            } catch { print("Add income failed: \(error)") }

        case .transfer:
            guard let toName = vm.toAccountName, let toId = accountByName[toName] else { return }
            do {
                try await DI.transfer.execute(
                    amount: Money(cents: abs(vm.amountCents)),
                    from: fromId,
                    to: toId,
                    note: vm.note,
                    date: vm.date,
                    cleared: vm.isCleared
                )
            } catch { print("Transfer failed: \(error)") }
        }
    }

    // MARK: Local mapper (Domain → UI)

    private func mapToVM(_ t: Transaction) -> TxVM {
        let accName = accountById[t.accountId]?.name ?? "Account"
        let toName  = t.counterpartyAccountId.flatMap { accountById[$0]?.name }
        let catName = t.categoryId.flatMap { categoryById[$0]?.name }

        let icon = t.categoryId
            .flatMap { categoryById[$0]?.icon }
            ?? {
                switch t.kind {
                case .expense:  return "minus.circle.fill"
                case .income:   return "plus.circle.fill"
                case .transfer: return "arrow.left.arrow.right.circle.fill"
                }
            }()

        let vmKind: TxVM.Kind = {
            switch t.kind {
            case .expense:  return .expense
            case .income:   return .income
            case .transfer: return .transfer
            }
        }()

        return TxVM(
            id: t.id,
            kind: vmKind,
            amountCents: t.amount.cents,
            accountName: accName,
            toAccountName: toName,
            categoryName: catName,
            icon: icon,
            note: t.note,
            date: t.date,
            isCleared: t.isCleared
        )
    }
    // MARK: Row actions

    private func toggleCleared(_ vm: TxVM) async {
        await updateCleared(vm, !vm.isCleared)
    }

    private func deleteTx(_ vm: TxVM) async {
        do {
            try await DI.txRepo.delete(id: vm.id)
        } catch {
            print("Delete failed: \(error)")
        }
    }

    /// Update only the `isCleared` flag without creating a new row.
    /// We build a domain `Transaction` with the SAME id and save; SD repo updates it.
    private func updateCleared(_ vm: TxVM, _ newValue: Bool) async {
        do {
            guard let fromId = accountByName[vm.accountName] else { return }
            let toId = vm.toAccountName.flatMap { accountByName[$0] }
            let catId = vm.categoryName.flatMap { categoryByName[$0] }

            let domain = Transaction(
                id: vm.id,
                kind: {
                    switch vm.kind {
                    case .expense:  return .expense
                    case .income:   return .income
                    case .transfer: return .transfer
                    }
                }(),
                amount: Money(cents: abs(vm.amountCents)),
                accountId: fromId,
                counterpartyAccountId: toId,
                categoryId: catId,
                note: vm.note,
                date: vm.date,
                isCleared: newValue
            )

            try await DI.txRepo.save(domain)   // SD repo updates existing row (same id)
        } catch {
            print("Update cleared failed: \(error)")
        }
    }

    // MARK: Totals

    private func recalcTotals() {
        let items = filtered(txs: txs)
        let income = items.filter { $0.kind == .income }.reduce(0) { $0 + abs($1.amountCents) }
        let expense = items.filter { $0.kind == .expense }.reduce(0) { $0 + abs($1.amountCents) }
        incomeCents = income
        expenseCents = expense
        netCents = income - expense
    }

    // MARK: Filtering & sectioning (UI side)

    private func filtered(txs: [TxVM]) -> [TxVM] {
        let (start, end) = monthBounds(for: filter.month)
        return txs.filter { t in
            (t.date >= start && t.date < end)
            && (filter.account == nil || t.accountName == filter.account || t.toAccountName == filter.account)
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
        let groups = Dictionary(grouping: txs) {
            Calendar.current.dateInterval(of: .month, for: $0.date)
            ?? DateInterval(start: .distantPast, end: .distantFuture)
        }
        return groups.keys
            .sorted(by: { $0.start > $1.start })
            .map { interval in
                let key = String(df.string(from: interval.start).prefix(20))
                return Sectioned(
                    monthId: key,
                    monthTitle: key,
                    items: groups[interval]!.sorted(by: { $0.date > $1.date })
                )
            }
    }

    private func monthBounds(for date: Date) -> (Date, Date) {
        let cal = Calendar.current
        let start = cal.date(from: cal.dateComponents([.year, .month], from: date))!
        let end = cal.date(byAdding: DateComponents(month: 1), to: start)!
        return (start, end)
    }

    // MARK: Persist / Restore filters

    private func persistFilters() {
        storedAccount = filter.account ?? ""
        storedCategory = filter.category ?? ""
        storedSearch = filter.search
        storedClearedOnly = filter.showClearedOnly
        storedMonthISO = monthISO(filter.month)
    }

    private func restoreFilters() {
        filter.account = storedAccount.isEmpty ? nil : storedAccount
        filter.category = storedCategory.isEmpty ? nil : storedCategory
        filter.search = storedSearch
        filter.showClearedOnly = storedClearedOnly
        if let d = parseMonthISO(storedMonthISO) { filter.month = d }
    }

    private func monthISO(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        f.timeZone = .current
        return f.string(from: date)
    }
    private func parseMonthISO(_ s: String) -> Date? {
        guard !s.isEmpty else { return nil }
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        f.timeZone = .current
        return f.date(from: s)
    }

    private func clearFilters() {
        filter = TxFilterState()
        persistFilters()
    }
}
