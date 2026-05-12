//
//  MeasurementRunner.swift
//  DatabaseBenchmarkKit
//
//  Created by Roman Antoniuk on 12.05.2026.
//


import Foundation
import CoreDomain
import Darwin

public actor MeasurementRunner {
    
    public init() {}
    
    /// Launches any asynchronous operation and measures its execution time
    public func runBenchmark(databaseName: String, operationName: String, operation: () async throws -> Void) async throws -> PerformanceResult {
        // Freeze memory before the start
        let memoryBefore = reportMemoryUsage()
        // Start the timer and the operation
        let clock = ContinuousClock()
        let duration = try await clock.measure {
            try await operation()
        }
        // Freeze memory after
        let memoryAfter = reportMemoryUsage()
        // Convert time to seconds (with fractional part for milliseconds)
        let seconds = Double(duration.components.seconds) + (Double(duration.components.attoseconds) / 1e18)
        // Calculate the difference. We use max(0, ...) because ARC can free memory during the test
        let memoryDiff = max(0, memoryAfter - memoryBefore)
        return PerformanceResult(databaseName: databaseName, operationName: operationName, durationInSeconds: seconds, memoryUsedInMegabytes: memoryDiff)
    }
    
    private func reportMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        if kerr == KERN_SUCCESS {
            return Double(info.resident_size) / (1024 * 1024)
        } else {
            return 0
        }
    }
    
}