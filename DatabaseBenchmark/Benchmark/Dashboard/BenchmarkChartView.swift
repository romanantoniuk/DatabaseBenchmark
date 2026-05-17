//
//  BenchmarkChartView.swift
//  DatabaseBenchmark
//
//  Created by Roman Antoniuk on 12.05.2026.
//

import SwiftUI
import Charts
import MeasurementLayer

struct BenchmarkChartView: View {
    
    let results: [PerformanceResult]
    let activeMetrics: [MemoryMetric]
    
    var body: some View {
        VStack(spacing: 20) {
            timeChart
            ForEach(activeMetrics) { metric in
                memoryChart(for: metric)
            }
        }
        .padding(.vertical)
    }
    
    private var timeChart: some View {
        VStack(alignment: .leading) {
            Text("Execution Time (Seconds)")
                .font(.headline)
            Chart(results) { result in
                BarMark(
                    x: .value("Database", result.databaseName),
                    y: .value("Time", result.durationInSeconds)
                )
                .foregroundStyle(by: .value("Operation", result.operationName))
                .position(by: .value("Operation", result.operationName))
            }
            .frame(height: 180)
            .chartLegend(position: .bottom)
        }
    }
    
    private func memoryChart(for metric: MemoryMetric) -> some View {
        VStack(alignment: .leading) {
            Text(metric.chartTitle)
                .font(.headline)
            Chart(results) { result in
                BarMark(
                    x: .value("Database", result.databaseName),
                    y: .value("Memory", result.memoryValue(for: metric))
                )
                .foregroundStyle(by: .value("Operation", result.operationName))
                .position(by: .value("Operation", result.operationName))
            }
            .frame(height: 180)
            .chartLegend(.hidden)
        }
    }
    
}

private extension MemoryMetric {
    
    var chartTitle: String {
        switch self {
        case .physFootprint:
            return "Memory Impact: Physical Footprint (MB)"
        case .residentSize:
            return "Memory Impact: Resident Size (MB)"
        }
    }
    
}

