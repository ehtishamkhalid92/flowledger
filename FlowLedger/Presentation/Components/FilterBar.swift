//
//  FilterBar.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI

struct FilterBar: View {
    @Binding var month: Date
    let accounts: [String]
    @Binding var selectedAccount: String?
    let categories: [String]
    @Binding var selectedCategory: String?
    @Binding var search: String
    @Binding var showClearedOnly: Bool

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                MonthPicker(date: $month)
                Toggle(isOn: $showClearedOnly) {
                    Image(systemName: showClearedOnly ? "checkmark.circle" : "circle")
                }
                .toggleStyle(.button)
                .help("Show cleared only")
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Chip(title: selectedAccount ?? "Account", systemImage: "creditcard", isActive: selectedAccount != nil) {
                        // simple inline menu
                    }.contextMenu {
                        Button("All Accounts") { selectedAccount = nil }
                        Divider()
                        ForEach(accounts, id: \.self) { acc in
                            Button(acc) { selectedAccount = acc }
                        }
                    }

                    Chip(title: selectedCategory ?? "Category", systemImage: "tag", isActive: selectedCategory != nil) {}
                        .contextMenu {
                            Button("All Categories") { selectedCategory = nil }
                            Divider()
                            ForEach(categories, id: \.self) { cat in
                                Button(cat) { selectedCategory = cat }
                            }
                        }

                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass")
                        TextField("Search note…", text: $search)
                            .textFieldStyle(.plain)
                            .disableAutocorrection(true)
                    }
                    .padding(.horizontal, 10).padding(.vertical, 8)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

// MARK: Helpers

struct Chip: View {
    let title: String
    let systemImage: String
    let isActive: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                Text(title)
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isActive ? Color.accentColor.opacity(0.15) : Color(.secondarySystemGroupedBackground))
            )
        }
        .buttonStyle(.plain)
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
