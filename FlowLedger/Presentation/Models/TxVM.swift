//
//  TxVM.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 09.11.2025.
//

import Foundation

struct TxVM: Identifiable, Hashable {
    enum Kind: String, CaseIterable { case expense, income, transfer }

    let id: String
    let kind: Kind
    let amountCents: Int
    let accountName: String
    let toAccountName: String?      // transfers only
    let categoryName: String?       // nil for transfers
    let icon: String
    let note: String?
    let date: Date
    let isCleared: Bool

    var signedAmount: Int {
        switch kind {
        case .expense:  return -abs(amountCents)
        case .income:   return  abs(amountCents)
        case .transfer: return  amountCents
        }
    }
}
