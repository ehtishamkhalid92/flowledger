//
//  SyncRepository.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import Foundation

public protocol SyncRepository {
    func syncNow() async throws
}
