//
//  MeasurementRunner.swift
//  MeasurementLayer
//
//  Created by Roman Antoniuk on 11.05.2026.
//

import Foundation
import CoreDomain

public actor MeasurementRunner {
    
    public init() {}
    
    /// Launches any asynchronous operation and measures its execution time
    public func runBenchmark(databaseName: String, operationName: String, operation: () async throws -> Void) async throws -> PerformanceResult {
        let clock = ContinuousClock()
        // measure automatically calculates the execution time of a block of code
        let duration = try await clock.measure {
            try await operation()
        }
        // Convert time to seconds (with fractional part for milliseconds)
        let seconds = Double(duration.components.seconds) + (Double(duration.components.attoseconds) / 1e18)
        return PerformanceResult(databaseName: databaseName, operationName: operationName, durationInSeconds: seconds)
    }
    
}
