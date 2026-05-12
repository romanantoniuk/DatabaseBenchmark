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
    
    var body: some View {
        VStack(spacing: 32) {
            timeChart
            memoryChart
            residentMemoryChart
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
            .frame(height: 220)
            .chartLegend(position: .bottom)
        }
    }
    
    private var memoryChart: some View {
        VStack(alignment: .leading) {
            Text("Memory Impact: Heap (MB)")
                .font(.headline)
            Chart(results) { result in
                BarMark(
                    x: .value("Database", result.databaseName),
                    y: .value("Memory", result.physFootprintDeltaMB)
                )
                .foregroundStyle(by: .value("Operation", result.operationName))
                .position(by: .value("Operation", result.operationName))
            }
            .frame(height: 220)
            .chartLegend(.hidden)
        }
    }
    
    private var residentMemoryChart: some View {
        VStack(alignment: .leading) {
            Text("Memory Impact: Resident (MB)")
                .font(.headline)
            Chart(results) { result in
                BarMark(
                    x: .value("Database", result.databaseName),
                    y: .value("Memory", result.residentSizeDeltaMB)
                )
                .foregroundStyle(by: .value("Operation", result.operationName))
                .position(by: .value("Operation", result.operationName))
            }
            .frame(height: 220)
            .chartLegend(.hidden)
        }
    }
    
}
