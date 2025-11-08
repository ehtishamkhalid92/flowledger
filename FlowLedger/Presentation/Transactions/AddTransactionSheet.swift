//
//  AddTransactionSheet.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI

struct AddTransactionSheet: View {
    let accounts: [String]
    let categories: [String]
    var onSave: (TxVM) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var kind: TxVM.Kind = .expense
    @State private var account: String = ""
    @State private var category: String = ""
    @State private var amountText: String = ""
    @State private var note: String = ""
    @State private var date: Date = .now
    @State private var isCleared: Bool = true

    var body: some View {
        NavigationStack {
            Form {
                Picker("Type", selection: $kind) {
                    ForEach(TxVM.Kind.allCases, id: \.self) { k in
                        Text(k.rawValue.capitalized).tag(k)
                    }
                }
                Picker("Account", selection: $account) {
                    ForEach(accounts, id: \.self) { Text($0) }
                }
                if kind != .transfer {
                    Picker("Category", selection: $category) {
                        Text("None").tag("")
                        ForEach(categories, id: \.self) { Text($0) }
                    }
                }
                TextField("Amount (e.g. 12.50)", text: $amountText)
                    .keyboardType(.decimalPad)
                TextField("Note (optional)", text: $note)
                DatePicker("Date", selection: $date, displayedComponents: .date)
                Toggle("Cleared", isOn: $isCleared)
            }
            .navigationTitle("Add Transaction")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.disabled(!canSave)
                }
            }
            .onAppear {
                account = accounts.first ?? ""
            }
        }
    }

    private var canSave: Bool {
        guard !account.isEmpty, let _ = cents(from: amountText) else { return false }
        if kind != .transfer, category.isEmpty { return false }
        return true
    }

    private func save() {
        guard let amount = cents(from: amountText) else { return }
        let icon: String = {
            switch kind {
            case .expense:  return "cart.fill"
            case .income:   return "arrow.down.circle.fill"
            case .transfer: return "arrow.left.arrow.right"
            }
        }()

        let vm = TxVM(
            id: UUID().uuidString,
            kind: kind,
            amountCents: amount,
            accountName: account,
            categoryName: kind == .transfer ? nil : category,
            icon: icon,
            note: note.isEmpty ? nil : note,
            date: date,
            isCleared: isCleared
        )
        onSave(vm)
        dismiss()
    }

    private func cents(from text: String) -> Int? {
        let normalized = text.replacingOccurrences(of: ",", with: ".")
        guard let d = Double(normalized) else { return nil }
        return Int((d * 100.0).rounded())
    }
}
