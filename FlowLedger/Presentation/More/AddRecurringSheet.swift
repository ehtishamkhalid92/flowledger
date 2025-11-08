//
//  AddRecurringSheet.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI

struct AddRecurringSheet: View {
    var onSave: (RecurringRule) -> Void

    @Environment(\.dismiss) private var dismiss

    // Input
    @State private var name: String = "Salary"
    @State private var kindIndex: Int = 1 // 0=expense,1=income,2=transfer
    @State private var amountStr: String = "6859.00"
    @State private var accountName: String = "Current"
    @State private var toAccountName: String = ""
    @State private var categoryName: String = "Salary"
    @State private var note: String = ""
    @State private var day: Int = 1

    var body: some View {
        NavigationStack {
            Form {
                Section("What") {
                    TextField("Name", text: $name)
                    Picker("Type", selection: $kindIndex) {
                        Text("Expense").tag(0)
                        Text("Income").tag(1)
                        Text("Transfer").tag(2)
                    }
                    TextField("Amount (e.g. 1200.00)", text: $amountStr)
                        .keyboardType(.decimalPad)
                    TextField("Category (optional)", text: $categoryName)
                    TextField("Note (optional)", text: $note)
                }
                Section("Accounts") {
                    TextField("From Account", text: $accountName)
                    if kindIndex == 2 {
                        TextField("To Account", text: $toAccountName)
                    }
                }
                Section("Recurrence") {
                    Stepper("Monthly day: \(day)", value: $day, in: 1...28)
                    Text("Weekly option can be added later")
                        .foregroundStyle(.secondary).font(.footnote)
                }
            }
            .navigationTitle("New Rule")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let rule = buildRule() {
                            onSave(rule)
                            dismiss()
                        }
                    }
                }
            }
        }
    }

    private func buildRule() -> RecurringRule? {
        // Resolve accounts/categories by name through DI (best effort)
        // We’ll do synchronous best-effort lookups; for a real screen you’d present pickers.
        let accounts = (try? awaitResult { try await DI.listAccounts.execute() }) ?? []
        let accountByName = Dictionary(uniqueKeysWithValues: accounts.map { ($0.name, $0.id) })

        let cats = (try? awaitResult { try await DI.categoryRepo.list(kind: nil) }) ?? []
        let catByName = Dictionary(uniqueKeysWithValues: cats.map { ($0.name, $0.id) })

        guard let accountId = accountByName[accountName] else { return nil }
        let toId = accountByName[toAccountName]
        let categoryId = catByName[categoryName]

        let cents = parseCHF(amountStr)
        let kind: TransactionKind = (kindIndex == 0 ? .expense : kindIndex == 1 ? .income : .transfer)

        let template = Transaction(
            kind: kind,
            amount: Money(cents: cents),
            accountId: accountId,
            counterpartyAccountId: toId,
            categoryId: categoryId,
            note: note.isEmpty ? nil : note,
            date: Date(),
            isCleared: true
        )

        return RecurringRule(
            id: UUID().uuidString,
            name: name,
            template: template,
            recurrence: .monthly(day: day),
            startDate: Date(),
            endDate: nil
        )
    }

    private func parseCHF(_ s: String) -> Int {
        let cleaned = s.replacingOccurrences(of: "CHF", with: "")
            .replacingOccurrences(of: "’", with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespaces)
        if let v = Double(cleaned) {
            return Int((v * 100.0).rounded())
        }
        return 0
    }
}

// Tiny helper to await inside non-async builders
private func awaitResult<T>(_ work: @escaping () async throws -> T) throws -> T {
    var result: Result<T, Error>!
    let sem = DispatchSemaphore(value: 0)
    Task {
        do { result = .success(try await work()) }
        catch { result = .failure(error) }
        sem.signal()
    }
    sem.wait()
    return try result.get()
}
