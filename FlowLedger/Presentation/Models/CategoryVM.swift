//
//  CategoryVM.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import Foundation

struct CategoryVM: Identifiable, Hashable {
    let id: String
    let name: String
    let kind: CategoryKind
    let icon: String
}
