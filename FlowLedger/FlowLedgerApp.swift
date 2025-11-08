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
    @Environment(\.scenePhase) private var scenePhase

    // SwiftData container
    private let container: ModelContainer = {
        let schema = Schema([
            AccountEntity.self,
            CategoryEntity.self,
            TransactionEntity.self,
            RecurringRuleEntity.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [config])
    }()

    init() {
        // Boot DI with SwiftData context
        DI.useSwiftData(context: ModelContext(container))
    }

    var body: some Scene {
        WindowGroup {
            AppAppearanceView {       // applies theme from AppSettings
                RootTabs()
            }
        }
        .modelContainer(container)
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                RecurringRunner.runIfNeededToday()
            }
        }
    }
}
