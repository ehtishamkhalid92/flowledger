//
//  SectionCard.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI

struct SectionCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content
        }
        .padding()
        .background(AppTheme.card)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(color: .black.opacity(0.08),
                radius: AppTheme.shadow.radius,
                y: AppTheme.shadow.y)
    }
}
