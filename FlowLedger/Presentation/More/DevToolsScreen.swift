//
//  DevToolsScreen.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI

struct DevToolsScreen: View {
    @AppStorage(AppSettings.Keys.debugBadges) private var showDebugBadges: Bool = false
    @AppStorage(AppSettings.Keys.verboseLogs) private var verboseLogs: Bool = false

    @State private var alert: AlertItem?

    var body: some View {
        List {
            Section("Flags") {
                Toggle("Show debug badges", isOn: $showDebugBadges)
                Toggle("Verbose logs", isOn: $verboseLogs)
            }

            Section("Data") {
                Button(role: .destructive) {
                    alert = .init(title: "Clear All Data",
                                  message: "UI-only right now. Will wipe SwiftData in data layer.",
                                  primary: .destructive(Text("OK")),
                                  secondary: .cancel())
                } label: {
                    Label("Clear all data (TODO)", systemImage: "trash")
                }

                Button {
                    alert = .init(title: "Seed Demo Data",
                                  message: "UI-only seeding. Will insert sample entities later.",
                                  primary: .default(Text("OK")),
                                  secondary: .cancel())
                } label: {
                    Label("Seed demo data (TODO)", systemImage: "square.and.arrow.down")
                }
            }

            Section("Export") {
                Button {
                    alert = .init(title: "Export Debug Logs",
                                  message: "No logs yet. Hook in later.",
                                  primary: .default(Text("OK")),
                                  secondary: .cancel())
                } label: {
                    Label("Export logs (TODO)", systemImage: "square.and.arrow.up")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Developer Options")
        .alert(item: $alert) { item in
            Alert(title: Text(item.title),
                  message: Text(item.message),
                  primaryButton: item.primary,
                  secondaryButton: item.secondary)
        }
    }

    private struct AlertItem: Identifiable {
        let id = UUID()
        let title: String
        let message: String
        let primary: Alert.Button
        let secondary: Alert.Button
    }
}
