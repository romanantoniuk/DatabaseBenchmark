//
//  BenchmarkDashboardResultRowView.swift
//  DatabaseBenchmark
//
//  Created by Roman Antoniuk on 12.05.2026.
//

import SwiftUI
import MeasurementLayer

struct BenchmarkDashboardResultRowView: View {

    let result: PerformanceResult
    let activeMetrics: [MemoryMetric]

    var body: some View {
        HStack(alignment: .top) {
            Text(result.operationName)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(result.formattedDuration)
                    .font(.system(.subheadline, design: .monospaced))
                    .bold()
                ForEach(activeMetrics) { metric in
                    HStack(spacing: 4) {
                        Image(systemName: metric.systemImage)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        Text(result.formattedMemory(for: metric))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 2)
    }
    
}
