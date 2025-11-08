//
//  AppSettings.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return "System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

enum AppSettings {
    enum Keys {
        static let appearance = "settings.appearance"
        static let currency   = "settings.currency"
        static let language   = "settings.language"
        static let icloud     = "settings.icloudSyncEnabled"
        static let debugBadges = "settings.debug.badges"
        static let verboseLogs = "settings.debug.verbose"
    }

    static let supportedCurrencies = ["CHF", "EUR", "USD", "PKR"]
    static let supportedLanguages = ["en", "de", "fr", "ur"] // placeholder; real i18n later
}
