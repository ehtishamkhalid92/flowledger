//
//  RecurringListScreen.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI

struct RecurringListScreen: View {
    @State private var rules: [RecurringRule] = []
    @State private var showingAdd = false

    var body: some View {
        List {
            Section {
                Button {
                    Task { await runToday() }
                } label: {
                    Label("Run for Today", systemImage: "play.circle.fill")
                }
            }

            Section("Active Rules") {
                if rules.isEmpty {
                    Text("No rules yet").foregroundStyle(.secondary)
                } else {
                    ForEach(rules, id: \.id) { r in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(r.name).bold()
                            Text(ruleSubtitle(r)).font(.footnote).foregroundStyle(.secondary)
                        }
                    }
                    .onDelete(perform: delete)
                }
            }
        }
        .navigationTitle("Recurring Rules")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAdd = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddRecurringSheet(onSave: { rule in
                Task {
                    try? await DI.saveRecurring.execute(rule)
                    await refresh()
                }
            })
            .presentationDetents([.medium])
        }
        .task { await refresh() }
    }

    private func refresh() async {
        do {
            rules = try await DI.recurringRepo.listActive()
        } catch {
            print("Recurring list error: \(error)")
        }
    }

    private func runToday() async {
        do {
            _ = try await DI.runRecurringForDate.execute(date: Date())
        } catch {
            print("Run recurring error: \(error)")
        }
    }

    private func delete(at offsets: IndexSet) {
        Task {
            for idx in offsets {
                let id = rules[idx].id
                try? await DI.recurringRepo.delete(id: id)
            }
            await refresh()
        }
    }

    private func ruleSubtitle(_ r: RecurringRule) -> String {
        switch r.recurrence {
        case .monthly(let d): return "Monthly on day \(d)"
        case .weekly(let w):  return "Weekly on weekday \(w)"
        }
    }
}
