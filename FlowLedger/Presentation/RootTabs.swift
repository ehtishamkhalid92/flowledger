//
//  RootTabs.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI

struct RootTabs: View {
    var body: some View {
        TabView {
            NavigationStack { OverviewScreen() }
                .tabItem { Label(String(localized: "tab.overview"), systemImage: "chart.pie.fill") }
            NavigationStack { TransactionsScreen() }
                .tabItem { Label(String(localized: "tab.transactions"), systemImage: "list.bullet.rectangle") }
            NavigationStack { AccountsScreen() }
                .tabItem { Label(String(localized: "tab.accounts"), systemImage: "creditcard.fill") }
            NavigationStack { ReportsScreen() }
                .tabItem { Label(String(localized: "tab.reports"), systemImage: "doc.text.magnifyingglass") }
            NavigationStack { Placeholder(title: "More") }
                .tabItem { Label(String(localized: "tab.more"), systemImage: "gearshape.fill") }
        }
    }
}

private struct Placeholder: View {
    let title: String
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.grid.2x2.fill").font(.system(size: 44))
            Text(title).font(.largeTitle).bold()
            Text("Coming soon").foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .navigationTitle(title)
    }
}
