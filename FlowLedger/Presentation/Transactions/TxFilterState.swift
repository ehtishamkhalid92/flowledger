//
//  TxFilterState.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 09.11.2025.
//

import Foundation

struct TxFilterState: Equatable {
    var month: Date = .now
    var account: String? = nil
    var category: String? = nil
    var search: String = ""
    var showClearedOnly: Bool = false
}
