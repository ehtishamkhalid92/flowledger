//
//  AppAppearance.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI

struct AppAppearanceView<Content: View>: View {
    @AppStorage(AppSettings.Keys.appearance)
    private var appearanceRaw: String = AppSettings.defaultAppearance

    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .preferredColorScheme(AppSettings.appearanceMode(from: appearanceRaw).colorScheme)
    }
}
