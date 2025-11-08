//
//  AccountCard.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI

struct AccountVM: Identifiable, Hashable {
    enum Kind { case current, savings, creditCard, cash }
    let id: String
    let name: String
    let kind: Kind
    let balanceCents: Int
    let deltaCents: Int

    var icon: String {
        switch kind {
        case .current:    return "banknote.fill"
        case .savings:    return "lock.fill"
        case .creditCard: return "creditcard.fill"
        case .cash:       return "wallet.pass.fill"
        }
    }
}

struct AccountCard: View {
    let vm: AccountVM

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: vm.icon).imageScale(.large)
                Spacer()
                let up = vm.deltaCents >= 0
                Text(up ? "↑" : "↓")
                    .font(.caption).bold()
                    .foregroundStyle(up ? .green : .red)
            }
            Text(vm.name).font(.headline)
            MoneyText(vm.balanceCents)
                .font(.title3).bold()
        }
        .padding(14)
        .background(AppTheme.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
