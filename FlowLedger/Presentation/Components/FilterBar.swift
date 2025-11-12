//
//  FilterBar.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI

struct FilterBar: View {
    // Inputs
    @Binding var month: Date

    let accounts: [String]
    @Binding var selectedAccount: String?

    let categories: [String]
    @Binding var selectedCategory: String?

    @Binding var search: String
    @Binding var showClearedOnly: Bool

    // Optional action hooks (parent can ignore)
    var onReload: (() -> Void)?         // e.g. reload from repo after month changes
    var onClearFilters: (() -> Void)?   // parent can reset persisted filters if desired

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // ── Top row: menu + month stepper
            HStack(spacing: 12) {
                // The icon is now an interactive Menu
                Menu {
                    Button("This Month", systemImage: "calendar") {
                        month = Date()
                        onReload?()
                    }
                    Button(showClearedOnly ? "Hide Cleared" : "Show Cleared",
                           systemImage: showClearedOnly ? "checkmark.circle.fill" : "circle") {
                        showClearedOnly.toggle()
                    }
                    Divider()
                    Button("Clear Filters", systemImage: "xmark.circle") {
                        selectedAccount = nil
                        selectedCategory = nil
                        search = ""
                        showClearedOnly = false
                        onClearFilters?()
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.circle")
                        .font(.title3)
                        .padding(6)
                        .contentShape(Rectangle())
                        .accessibilityLabel("Filter menu")
                }

                // Simple month stepper
                HStack(spacing: 8) {
                    Button {
                        month = Calendar.current.date(byAdding: .month, value: -1, to: month) ?? month
                        onReload?()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    Text(monthTitle(month))
                        .font(.headline)
                        .monospacedDigit()

                    Button {
                        month = Calendar.current.date(byAdding: .month, value: 1, to: month) ?? month
                        onReload?()
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
                .buttonStyle(.plain)

                Spacer()
            }

            // ── Chips / fields row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    // Account pill
                    Menu {
                        Button("All Accounts", action: { selectedAccount = nil })
                        ForEach(accounts, id: \.self) { acc in
                            Button(acc, action: { selectedAccount = acc })
                        }
                    } label: {
                        pillLabel(title: "Account", value: selectedAccount)
                    }

                    // Category pill
                    Menu {
                        Button("All Categories", action: { selectedCategory = nil })
                        ForEach(categories, id: \.self) { cat in
                            Button(cat, action: { selectedCategory = cat })
                        }
                    } label: {
                        pillLabel(title: "Category", value: selectedCategory)
                    }

                    // Search field
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass")
                        TextField("Search note…", text: $search)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
    }

    // MARK: helpers

    private func monthTitle(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f.string(from: date)
    }

    private func pillLabel(title: String, value: String?) -> some View {
        HStack(spacing: 6) {
            Text(title)
            if let v = value { Text(v).foregroundStyle(.secondary) }
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct MonthPicker: View {
    @Binding var date: Date
    var body: some View {
        HStack(spacing: 0) {
            Button {
                date = Calendar.current.date(byAdding: .month, value: -1, to: date) ?? date
            } label: { Image(systemName: "chevron.left") }
            .buttonStyle(.plain).padding(.trailing, 6)

            Text(date.formatted(.dateTime.month().year()))
                .font(.headline)

            Button {
                date = Calendar.current.date(byAdding: .month, value: 1, to: date) ?? date
            } label: { Image(systemName: "chevron.right") }
            .buttonStyle(.plain).padding(.leading, 6)
        }
        .padding(.horizontal, 10).padding(.vertical, 8)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
