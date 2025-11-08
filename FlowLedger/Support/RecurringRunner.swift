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

    static var isEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: enabledKey) == nil {
                UserDefaults.standard.set(true, forKey: enabledKey) // Default ON
            }
            return UserDefaults.standard.bool(forKey: enabledKey)
        }
        set { UserDefaults.standard.set(newValue, forKey: enabledKey) }
    }

    static func runIfNeededToday() {
        guard isEnabled else { return }
        let today = todayStamp()
        if UserDefaults.standard.string(forKey: lastRunKey) == today { return }

        Task {
            do {
                _ = try await DI.runRecurringForDate.execute(date: Date())
                UserDefaults.standard.set(today, forKey: lastRunKey)
            } catch {
                print("⚠️ Recurring auto-run failed: \(error)")
            }
        }
    }

    static func forceRunToday() {
        Task {
            do {
                _ = try await DI.runRecurringForDate.execute(date: Date())
                UserDefaults.standard.set(todayStamp(), forKey: lastRunKey)
                print("✅ Recurring rules executed manually")
            } catch {
                print("⚠️ Recurring manual run failed: \(error)")
            }
        }
    }

    private static func todayStamp() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd"
        return f.string(from: Date())
    }
}
