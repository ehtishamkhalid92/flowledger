//
//  RecurringRunner.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import Foundation

enum RecurringRunner {
    private static let lastRunKey = "recurring.lastRunYMD"
    private static let enabledKey = "recurring.autoRun.enabled"

    /// Whether auto-run is enabled (defaults to true)
    static var isEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: enabledKey) == nil {
                UserDefaults.standard.set(true, forKey: enabledKey) // Default ON
            }
            return UserDefaults.standard.bool(forKey: enabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: enabledKey)
        }
    }

    /// Called automatically on app start to run recurring transactions once per day
    static func runIfNeededToday() {
        guard isEnabled else { return }
        let today = todayStamp()
        if UserDefaults.standard.string(forKey: lastRunKey) == today { return }

        Task {
            do {
                let count = try await DI.runRecurringForDate.execute(date: Date())
                UserDefaults.standard.set(today, forKey: lastRunKey)
                print("✅ RecurringRunner: auto-run completed (\(count) transactions).")
            } catch {
                print("⚠️ RecurringRunner: auto-run failed — \(error)")
            }
        }
    }

    /// Manual “Run Now” trigger from the More → Automation section
    static func forceRunToday() {
        Task {
            do {
                let count = try await DI.runRecurringForDate.execute(date: Date())
                UserDefaults.standard.set(todayStamp(), forKey: lastRunKey)
                print("✅ RecurringRunner: manual run executed (\(count) transactions).")
            } catch {
                print("⚠️ RecurringRunner: manual run failed — \(error)")
            }
        }
    }

    /// Utility: compact YYYYMMDD string for today's date
    private static func todayStamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: Date())
    }
}
