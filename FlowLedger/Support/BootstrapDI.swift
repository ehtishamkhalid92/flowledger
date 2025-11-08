//
//  BootstrapDI.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI
import SwiftData

/// Wrap your root view with `BootstrapDI` so we can:
/// 1) Point DI to SwiftData repos using the live ModelContext
/// 2) Seed initial data (only if empty)
struct BootstrapDI<Content: View>: View {
    @Environment(\.modelContext) private var context
    private let content: Content

    init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .task {
                // Switch DI to SwiftData-backed repositories
                DI.useSwiftData(context: context)
                // Seed on first launch (safe if already seeded)
                try? await MainActor.run {
                    try seedIfEmpty(context: context)
                }
            }
    }
}
