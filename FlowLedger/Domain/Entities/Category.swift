//
//  Category.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import Foundation

public enum CategoryKind: String, Codable { case expense, income }

public struct Category: Identifiable, Hashable, Codable {
    public let id: CategoryID
    public var name: String
    public var kind: CategoryKind
    public var icon: String   // SF Symbol name

    public init(id: CategoryID = UUID().uuidString, name: String, kind: CategoryKind, icon: String) {
        self.id = id; self.name = name; self.kind = kind; self.icon = icon
    }
}
