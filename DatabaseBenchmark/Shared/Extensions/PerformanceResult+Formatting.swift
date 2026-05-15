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
        return "\(prefix): \(Self.formattedMemoryDelta(value))"
    }

    private static func formattedMemoryDelta(_ valueInMB: Double) -> String {
        let bytes = abs(valueInMB) * 1_048_576
        let sign = valueInMB > 0 ? "+" : valueInMB < 0 ? "-" : ""
        if bytes == 0 {
            return "0 B"
        }
        if bytes < 1 {
            return "<1 B"
        }
        if bytes < 1024 {
            return String(format: "\(sign)%.0f B", bytes)
        }
        let kilobytes = bytes / 1024
        if kilobytes < 1024 {
            return String(format: "\(sign)%.1f KB", kilobytes)
        }
        let megabytes = kilobytes / 1024
        if megabytes < 1024 {
            return String(format: "\(sign)%.2f MB", megabytes)
        }
        return String(format: "\(sign)%.2f GB", megabytes / 1024)
    }

}
