//
//  FlowLedgerApp.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI
import SwiftData

@main
struct FlowLedgerApp: App {
    @AppStorage(AppSettings.Keys.appearance) private var appearanceRaw: String = AppearanceMode.system.rawValue

    private var appearance: AppearanceMode {
        AppearanceMode(rawValue: appearanceRaw) ?? .system
    }

    // Build a SwiftData container (local store). Toggle `inMemory:` for UI testing if needed.
    private let container: ModelContainer = {
        do { return try SwiftDataStack.modelContainer(inMemory: false) }
        catch {
            fatalError("SwiftData container failed: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            // BootstrapDI reads the ModelContext and points DI to SwiftData repos.
            BootstrapDI {
                RootTabs()
                    .preferredColorScheme(appearance.colorScheme)
            }
        }
        .modelContainer(container)
    }
}
