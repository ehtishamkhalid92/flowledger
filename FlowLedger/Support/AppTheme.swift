//
//  AppTheme.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 08.11.2025.
//

import SwiftUI

enum AppTheme {
    static let bg = Color(.systemGroupedBackground)
    static let card = Color(.secondarySystemGroupedBackground)
    static let expense = Color.red
    static let income  = Color.green

    static func section(_ text: String) -> some View {
        Text(text).font(.title2).bold()
    }
}

struct SectionCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) { content }
            .padding(16)
            .background(AppTheme.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
