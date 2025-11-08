//
//  FlowLedgerApp.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI

@main
struct FlowLedgerApp: App {
    @AppStorage(AppSettings.Keys.appearance) private var appearanceRaw: String = AppearanceMode.system.rawValue

    private var appearance: AppearanceMode {
        AppearanceMode(rawValue: appearanceRaw) ?? .system
    }

    var body: some Scene {
        WindowGroup {
            RootTabs()
                .preferredColorScheme(appearance.colorScheme) // system/dark/light
        }
    }
}
