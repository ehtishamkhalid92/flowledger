//
//  MoreScreen.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI

struct MoreScreen: View {
    // Persisted settings
    @AppStorage(AppSettings.Keys.appearance) private var appearanceRaw: String = AppearanceMode.system.rawValue
    @AppStorage(AppSettings.Keys.currency)   private var currency: String = "CHF"
    @AppStorage(AppSettings.Keys.language)   private var language: String = "en"
    @AppStorage(AppSettings.Keys.icloud)     private var iCloudEnabled: Bool = false

    var body: some View {
        List {
            Section("Appearance") {
                Picker("Theme", selection: $appearanceRaw) {
                    ForEach(AppearanceMode.allCases, id: \.self) { mode in
                        Text(mode.label).tag(mode.rawValue)
                    }
                }
            }

            Section {
                Picker("Currency", selection: $currency) {
                    ForEach(AppSettings.supportedCurrencies, id: \.self) { code in
                        Text(code).tag(code)        // tag matches @AppStorage(String)
                    }
                }

                Picker("Language", selection: $language) {
                    ForEach(AppSettings.supportedLanguages, id: \.self) { lang in
                        Text(lang.uppercased()).tag(lang)
                    }
                }

                Toggle(isOn: $iCloudEnabled) {
                    Label("iCloud Sync (placeholder)", systemImage: "icloud")
                }
            } header: {
                Text("Preferences")
            } footer: {
                Text("Language and iCloud toggles are UI placeholders for now. Actual localization and CloudKit sync will be wired later.")
            }

            Section("Developer") {
                NavigationLink {
                    DevToolsScreen()
                } label: {
                    Label("Developer Options", systemImage: "wrench.and.screwdriver")
                }
            }

            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Build")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Settings")
    }
}

