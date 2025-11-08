//
//  AppSettings.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI

// MARK: - Appearance

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

// MARK: - App Settings

enum AppSettings {
    enum Keys {
        static let appearance   = "settings.appearance"
        static let currency     = "settings.currency"
        static let language     = "settings.language"
        static let icloud       = "settings.icloudSyncEnabled"
        static let debugBadges  = "settings.debug.badges"
        static let verboseLogs  = "settings.debug.verbose"
    }

    // Supported lists
    static let supportedCurrencies = ["CHF", "EUR", "USD", "PKR"]
    static let supportedLanguages  = ["en", "de", "fr", "ur"] // placeholder; real i18n later

    // Defaults used by @AppStorage initial values
    static let defaultAppearance = AppearanceMode.system.rawValue
    static let defaultCurrency   = "CHF"
    static let defaultLanguage   = "en"

    // Helper to decode appearance raw value
    static func appearanceMode(from raw: String) -> AppearanceMode {
        AppearanceMode(rawValue: raw) ?? .system
    }
}
