//
//  AddTransactionSheet.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI

struct AddTransactionSheet: View {
    // Inputs from parent
    var accounts: [String]
    var categories: [String]
    var preset: TxPreset? = nil
    var onSave: (TxVM) -> Void

    @Environment(\.dismiss) private var dismiss

    // Form state
    @State private var kindIndex: Int = 0 // 0=expense, 1=income, 2=transfer
    @State private var amountText: String = ""
    @State private var fromAccount: String = ""
    @State private var toAccount: String = ""
    @State private var category: String = ""
    @State private var note: String = ""
    @State private var date: Date = Date()
    @State private var isCleared: Bool = true

    // Derived
    private var isTransfer: Bool { kindIndex == 2 }
    private var isIncome: Bool { kindIndex == 1 }
    private var isExpense: Bool { kindIndex == 0 }

    private var saveEnabled: Bool {
        let cents = parseCents(amountText)
        guard cents > 0 else { return false }
        guard accounts.contains(fromAccount) else { return false }
        if isTransfer {
            return accounts.contains(toAccount) && toAccount != fromAccount
        } else {
            return !category.isEmpty && categories.contains(category)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Type & Amount") {
                    Picker("Type", selection: $kindIndex) {
                        Text("Expense").tag(0)
                        Text("Income").tag(1)
                        Text("Transfer").tag(2)
                    }
                    .pickerStyle(.segmented)

                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("0.00", text: $amountText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section("Accounts") {
                    Picker("From", selection: $fromAccount) {
                        ForEach(accounts, id: \.self) { Text($0).tag($0) }
                    }
                    if isTransfer {
                        Picker("To", selection: $toAccount) {
                            ForEach(accounts, id: \.self) { Text($0).tag($0) }
                        }
                    }
                }

                if !isTransfer {
                    Section("Category") {
                        Picker("Category", selection: $category) {
                            ForEach(categories, id: \.self) { Text($0).tag($0) }
                        }
                    }
                }

                Section("Details") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    Toggle("Cleared", isOn: $isCleared)
                    TextField("Note (optional)", text: $note)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
            }
            .navigationTitle(preset == nil ? "Add Transaction" : "Edit Transaction")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!saveEnabled)
                }
            }
            .onAppear(perform: seedFromPresetOrDefaults)
        }
    }

    // MARK: - Preset & save

    private func seedFromPresetOrDefaults() {
        if let p = preset {
            switch p.kind {
            case .expense:  kindIndex = 0
            case .income:   kindIndex = 1
            case .transfer: kindIndex = 2
            }
            amountText = String(format: "%.2f", Double(p.amountCents) / 100.0)
            fromAccount = p.accountName ?? accounts.first ?? ""
            toAccount = p.toAccountName ?? (accounts.dropFirst().first ?? accounts.first ?? "")
            category = p.categoryName ?? categories.first ?? ""
            note = p.note
            date = p.date
            isCleared = p.cleared
        } else {
            // defaults
            if fromAccount.isEmpty, let first = accounts.first { fromAccount = first }
            if toAccount.isEmpty, let second = accounts.dropFirst().first ?? accounts.first { toAccount = second }
            if category.isEmpty, let cat = categories.first { category = cat }
        }
    }

    private func save() {
        let cents = parseCents(amountText)
        guard cents > 0 else { return }

        let kind: TxVM.Kind = {
            switch kindIndex {
            case 0: return .expense
            case 1: return .income
            default: return .transfer
            }
        }()

        let vm = TxVM(
            id: preset == nil ? UUID().uuidString : UUID().uuidString, // we delete & recreate on edit
            kind: kind,
            amountCents: cents,
            accountName: fromAccount,
            toAccountName: isTransfer ? toAccount : nil,
            categoryName: isTransfer ? nil : category,
            icon: iconFor(kind),
            note: note.isEmpty ? nil : note,
            date: date,
            isCleared: isCleared
        )

        onSave(vm)
        dismiss()
    }

    // MARK: - Helpers

    private func parseCents(_ s: String) -> Int {
        let cleaned = s
            .replacingOccurrences(of: "CHF", with: "")
            .replacingOccurrences(of: "€", with: "")
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: "’", with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if let v = Double(cleaned) { return max(0, Int((v * 100.0).rounded())) }
        return 0
    }

    private func iconFor(_ kind: TxVM.Kind) -> String {
        switch kind {
        case .expense:  return "minus.circle.fill"
        case .income:   return "plus.circle.fill"
        case .transfer: return "arrow.left.arrow.right.circle.fill"
        }
    }
}

// Prefill container for editing
struct TxPreset {
    let kind: TxVM.Kind
    let amountCents: Int
    let accountName: String?
    let toAccountName: String?
    let categoryName: String?
    let note: String
    let date: Date
    let cleared: Bool
}
