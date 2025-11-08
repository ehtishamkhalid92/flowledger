//
//  TransactionRow.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI

struct TransactionRow: View {
    let vm: TxVM

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .frame(width: 42, height: 42)
                Image(systemName: vm.icon).imageScale(.medium)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(vm.categoryName ?? (vm.kind == .transfer ? "Transfer" : ""))
                    .font(.headline)
                HStack(spacing: 6) {
                    Text(vm.accountName).font(.caption).foregroundStyle(.secondary)
                    if let note = vm.note, !note.isEmpty {
                        Text("· \(note)").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            MoneyText(vm.signedAmount)
                .foregroundStyle(colorForAmount)
                .font(.headline)

            if vm.isCleared {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(.secondary).imageScale(.small)
            }
        }
        .contentShape(Rectangle())
    }

    private var colorForAmount: Color {
        switch vm.kind {
        case .expense:  return .red
        case .income:   return .green
        case .transfer: return .secondary
        }
    }
}
