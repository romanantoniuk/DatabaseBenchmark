//
//  PerformanceResult+Formatting.swift
//  DatabaseBenchmark
//
//  Created by Roman Antoniuk on 12.05.2026.
//

import Foundation
import MeasurementLayer

extension PerformanceResult {

    var formattedDuration: String {
        if durationInSeconds < 1 {
            return String(format: "%.1f ms", durationInSeconds * 1000)
        }
        return String(format: "%.4f s", durationInSeconds)
    }

    func memoryValue(for metric: MemoryMetric) -> Double {
        switch metric {
        case .physFootprint:
            physFootprintDeltaMB
        case .residentSize:
            residentSizeDeltaMB
        }
    }

    func formattedMemory(for metric: MemoryMetric) -> String {
        let value = memoryValue(for: metric)
        let prefix: String
        switch metric {
        case .physFootprint:
            prefix = "heap"
        case .residentSize:
            prefix = "res"
        }
        if value < 0.01 {
            return "\(prefix): <0.01 MB"
        }
        return String(format: "\(prefix): +%.2f MB", value)
    }

}
