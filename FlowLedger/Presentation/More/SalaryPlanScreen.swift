//
//  SalaryPlanScreen.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI

struct SalaryPlanScreen: View {
    @State private var plan: SalaryPlan = SalaryPlanStore.load()
    @State private var showingAdd = false
    @State private var showingRun = false
    @State private var salaryText = "6859.00" // CHF demo

    var body: some View {
        List {
            Section("Source") {
                HStack {
                    Text("From account")
                    Spacer()
                    TextField("Current", text: Binding(
                        get: { plan.sourceAccountName },
                        set: { plan.sourceAccountName = $0 }
                    ))
                    .multilineTextAlignment(.trailing)
                }
            }

            Section("Allocations") {
                if plan.items.isEmpty {
                    Text("No allocations. Add one below.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(plan.items) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name).bold()
                            Text(subtitle(for: item))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete(perform: delete)
                }
                Button {
                    showingAdd = true
                } label: {
                    Label("Add Allocation", systemImage: "plus.circle.fill")
                }
            }

            Section("Run") {
                Button {
                    showingRun = true
                } label: {
                    Label("Run Now…", systemImage: "play.circle.fill")
                }
            }
        }
        .navigationTitle("Salary Plan")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    SalaryPlanStore.save(plan)
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddAllocationSheet { newItem in
                plan.items.append(newItem)
                SalaryPlanStore.save(plan)
            }
            .presentationDetents([.medium])
        }
        .alert("Enter salary amount (CHF)", isPresented: $showingRun) {
            TextField("6859.00", text: $salaryText)
                .keyboardType(.decimalPad)
            Button("Cancel", role: .cancel) {}
            Button("Run") { Task { await runNow() } }
        } message: {
            Text("Allocations will be created dated today from the source account.")
        }
    }

    private func subtitle(for item: SalaryAllocationItem) -> String {
        let amt: String = {
            switch item.amount {
            case .percent(let p): return String(format: "%.0f%%", p)
            case .fixedCents(let c): return MoneyFormat.chf(c)   // <-- here
            }
        }()
        switch item.action {
        case .transferToAccount(let t): return "\(amt) → account “\(t)”"
        case .expenseToCategory(let c): return "\(amt) → category “\(c)”"
        }
    }

    private func delete(at offsets: IndexSet) {
        plan.items.remove(atOffsets: offsets)
        SalaryPlanStore.save(plan)
    }

    private func runNow() async {
        let cents = parseCHF(salaryText)
        guard cents > 0 else { return }
        do {
            _ = try await DI.runSalaryAllocation.execute(salaryCents: cents, date: Date())
        } catch {
            print("Run salary allocation failed: \(error)")
        }
    }

    private func parseCHF(_ s: String) -> Int {
        let cleaned = s
            .replacingOccurrences(of: "CHF", with: "")
            .replacingOccurrences(of: "’", with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if let v = Double(cleaned) { return Int((v * 100.0).rounded()) }
        return 0
    }
}

// MARK: - Add sheet

private struct AddAllocationSheet: View {
    var onAdd: (SalaryAllocationItem) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var typeIndex: Int = 0 // 0 transfer, 1 expense
    @State private var target: String = "" // account or category name
    @State private var amountMode: Int = 0 // 0 %, 1 fixed
    @State private var percentText: String = "10"
    @State private var fixedText: String = "100.00"

    var body: some View {
        NavigationStack {
            Form {
                Section("What") {
                    TextField("Name", text: $name)
                    Picker("Action", selection: $typeIndex) {
                        Text("Transfer to account").tag(0)
                        Text("Expense to category").tag(1)
                    }
                    TextField(typeIndex == 0 ? "Target account name" : "Category name", text: $target)
                }

                Section("Amount") {
                    Picker("Mode", selection: $amountMode) {
                        Text("Percent").tag(0)
                        Text("Fixed (CHF)").tag(1)
                    }
                    if amountMode == 0 {
                        TextField("10", text: $percentText).keyboardType(.numberPad)
                    } else {
                        TextField("100.00", text: $fixedText).keyboardType(.decimalPad)
                    }
                }
            }
            .navigationTitle("New Allocation")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        guard let item = buildItem() else { return }
                        onAdd(item)
                        dismiss()
                    }
                }
            }
        }
    }

    private func buildItem() -> SalaryAllocationItem? {
        guard !name.isEmpty, !target.isEmpty else { return nil }
        let action: AllocationAction = (typeIndex == 0)
            ? .transferToAccount(targetAccountName: target)
            : .expenseToCategory(categoryName: target)

        let amount: AllocationAmount = (amountMode == 0)
            ? .percent(Double(percentText) ?? 0)
            : .fixedCents(parseCHF(fixedText))

        return SalaryAllocationItem(name: name, action: action, amount: amount)
    }

    private func parseCHF(_ s: String) -> Int {
        let cleaned = s
            .replacingOccurrences(of: "CHF", with: "")
            .replacingOccurrences(of: "’", with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if let v = Double(cleaned) { return Int((v * 100.0).rounded()) }
        return 0
    }
}
