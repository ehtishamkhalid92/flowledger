//
//  Errors.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import Foundation

public enum DomainError: Error, LocalizedError {
    case notFound
    case invalidInput(String)
    case conflict(String)

    public var errorDescription: String? {
        switch self {
        case .notFound: return "Item not found."
        case .invalidInput(let msg): return msg
        case .conflict(let msg): return msg
        }
    }
}
