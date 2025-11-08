//
//  AppTheme.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI

enum AppTheme {
    // MARK: - Colors
    static let bg = Color(.systemGroupedBackground)
    static let card = Color(.secondarySystemGroupedBackground)
    static let accent = Color.accentColor

    // MARK: - Text Styles
    static func section(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 4)
    }

    // MARK: - Shadows & Corner Radius
    static let cornerRadius: CGFloat = 16
    static let shadow = ShadowStyle(radius: 4, y: 1)
}

struct ShadowStyle {
    let radius: CGFloat
    let y: CGFloat
}
