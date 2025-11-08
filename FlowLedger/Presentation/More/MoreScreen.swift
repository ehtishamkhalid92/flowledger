
import SwiftUI

struct MoreScreen: View {
    @AppStorage(AppSettings.Keys.appearance) private var appearanceRaw: String = AppSettings.defaultAppearance
    @AppStorage(AppSettings.Keys.currency)   private var currency: String      = AppSettings.defaultCurrency
    @AppStorage(AppSettings.Keys.language)   private var language: String      = AppSettings.defaultLanguage

    @State private var iCloudEnabled = false

    var body: some View {
        List {
            // MARK: Appearance
            Section {
                Picker("Theme", selection: $appearanceRaw) {
                    ForEach(AppearanceMode.allCases, id: \.rawValue) { mode in
                        Text(mode.label).tag(mode.rawValue)
                    }
                }
            } header: {
                Text("Appearance")
            }

            // MARK: Preferences
            Section {
                Picker("Currency", selection: $currency) {
                    ForEach(AppSettings.supportedCurrencies, id: \.self) { code in
                        Text(code).tag(code)
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

            // MARK: Automation
            Section {
                Toggle(isOn: Binding(
                    get: { RecurringRunner.isEnabled },
                    set: { RecurringRunner.isEnabled = $0 }
                )) {
                    Label("Auto-run Recurring (daily)", systemImage: "clock.badge.checkmark")
                }

                Button {
                    RecurringRunner.forceRunToday()
                } label: {
                    Label("Run Recurring Now", systemImage: "play.circle.fill")
                }
            } header: {
                Text("Automation")
            }

            // MARK: Tools
            Section {
                NavigationLink("Recurring Rules", destination: RecurringListScreen())
                NavigationLink("Developer Tools", destination: DevToolsScreen())
            } header: {
                Text("Tools")
            }

            Section {
                Label("FlowLedger v1.0", systemImage: "info.circle")
                Text("Made with SwiftUI + SwiftData")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } header: {
                Text("About")
            }
        }
        .navigationTitle("More")
    }
}

#Preview {
    NavigationStack { MoreScreen() }
}
