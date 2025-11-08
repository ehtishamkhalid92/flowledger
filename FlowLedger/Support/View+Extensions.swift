//
//  View+Extensions.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI

extension View {
    func animate(_ value: Bool, duration: Double = 0.25) -> some View {
        withAnimation(.easeInOut(duration: duration)) { self }
    }

    func cardify() -> some View {
        self
            .padding()
            .background(AppTheme.card)
            .cornerRadius(AppTheme.cornerRadius)
            .shadow(color: .black.opacity(0.06),
                    radius: AppTheme.shadow.radius,
                    y: AppTheme.shadow.y)
    }
}
