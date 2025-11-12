
//  DonutChart.swift
//  FlowLedger


import SwiftUI

struct DonutChart: View {
    struct Slice { let label: String; let value: Double }
    let slices: [Slice]

    private var total: Double { max(1.0, slices.reduce(0) { $0 + $1.value }) }

    var body: some View {
        ZStack {
            ForEach(Array(slices.enumerated()), id: \.offset) { idx, slice in
                let start = angle(at: idx)
                let end   = angle(at: idx + 1)

                Circle()
                    .trim(from: start, to: end)
                    .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .fill(Self.color(for: idx))
                    .rotationEffect(.degrees(-90))
            }

            // Center total label
            Text(MoneyText.formatCents(Int(total)))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func angle(at index: Int) -> CGFloat {
        let sumBefore = slices.prefix(index).reduce(0) { $0 + $1.value }
        return CGFloat(sumBefore / total)
    }

    static func color(for idx: Int) -> Color {
        let palette: [Color] = [.blue, .green, .orange, .pink, .purple, .teal, .red, .indigo]
        return palette[idx % palette.count]
    }
}
