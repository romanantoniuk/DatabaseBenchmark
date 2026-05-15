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

    private let configuration: Configuration
    
    public init(configuration: Configuration = .default) {
        self.configuration = configuration
    }
    
    public func runBenchmark(databaseName: String, operationName: String, setup: (() async throws -> Void)? = nil, teardown: (() async throws -> Void)? = nil, operation: () async throws -> Void) async throws -> PerformanceResult {
        for _ in 0..<configuration.warmupIterations {
            try await setup?()
            try await operation()
            try await teardown?()
            await drainMemory()
            try await pause()
        }
        var results: [RunResult] = []
        results.reserveCapacity(configuration.iterations)
        for _ in 0..<configuration.iterations {
            try await setup?()
            await drainMemory()
            let result = try await measure(operation)
            try await teardown?()
            results.append(result)
            try await pause()
        }
        let summary = aggregate(results)
        return PerformanceResult(
            databaseName: databaseName,
            operationName: operationName,
            durationInSeconds: summary.duration,
            physFootprintDeltaMB: summary.physFootprintDelta,
            residentSizeDeltaMB: summary.residentSizeDelta
        )
    }
    
    private func measure(_ operation: () async throws -> Void) async throws -> RunResult {
        switch configuration.memoryStrategy {
        case .delta:
            return try await measureWithDelta(operation)
        case .peak(let interval):
            return try await measureWithPeak(operation, samplingInterval: interval)
        }
    }
    
    private func measureWithDelta(_ operation: () async throws -> Void) async throws -> RunResult {
        let before = MemorySnapshot.current()
        let clock = ContinuousClock()
        let duration = try await clock.measure {
            try await operation()
        }
        let delta = MemorySnapshot.current().delta(from: before)
        return RunResult(duration: duration.seconds, physFootprintDelta: delta.physFootprint, residentSizeDelta: delta.residentSize)
    }

    private func measureWithPeak(_ operation: () async throws -> Void, samplingInterval: Duration) async throws -> RunResult {
        let baseline = MemorySnapshot.current()
        let sampler = MemorySampler(baseline: baseline, interval: samplingInterval)
        await sampler.sample()
        let samplerTask = Task.detached(priority: .utility) {
            await sampler.run()
        }
        var operationError: Error?
        let clock = ContinuousClock()
        let duration = await clock.measure {
            do {
                try await operation()
            } catch {
                operationError = error
            }
        }
        await sampler.sample()
        samplerTask.cancel()
        let peak = await sampler.peak
        if let error = operationError {
            throw error
        }
        return RunResult(duration: duration.seconds, physFootprintDelta: peak.physFootprint, residentSizeDelta: peak.residentSize)
    }

    private func aggregate(_ results: [RunResult]) -> RunResult {
        guard let first = results.first else {
            return RunResult(duration: 0, physFootprintDelta: 0, residentSizeDelta: 0)
        }
        guard results.count > 1 else {
            return first
        }
        return RunResult(duration: median(results.map(\.duration)), physFootprintDelta: median(results.map(\.physFootprintDelta)), residentSizeDelta: median(results.map(\.residentSizeDelta)))
    }

    private func median(_ values: [Double]) -> Double {
        let sorted = values.sorted()
        let mid = sorted.count / 2
        return sorted.count.isMultiple(of: 2) ? (sorted[mid - 1] + sorted[mid]) / 2 : sorted[mid]
    }
    
    nonisolated func currentMemoryMB() -> Double {
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / 4)
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        guard result == KERN_SUCCESS else {
            return 0
        }
        return Double(info.phys_footprint) / 1_048_576
    }
    
    private func drainMemory() async {
        autoreleasepool { }
        await Task.yield()
    }
    
    private func pause() async throws {
        guard configuration.pauseBetweenRuns > .zero else {
            return
        }
        try await Task.sleep(for: configuration.pauseBetweenRuns)
    }
    
}

extension MeasurementRunner {
    
    public struct Configuration: Sendable {
        
        public let iterations: Int
        public let warmupIterations: Int
        public let pauseBetweenRuns: Duration
        public let memoryStrategy: MemoryStrategy
        
        public init(iterations: Int = 5, warmupIterations: Int = 2, pauseBetweenRuns: Duration = .milliseconds(100), memoryStrategy: MemoryStrategy = .peak(samplingInterval: .milliseconds(5))) {
            self.iterations = max(1, iterations)
            self.warmupIterations = max(0, warmupIterations)
            self.pauseBetweenRuns = pauseBetweenRuns
            self.memoryStrategy = memoryStrategy
        }
        
        public static let `default` = Self()
        public static let quick = Self(iterations: 3, warmupIterations: 1)
        public static let precise = Self(iterations: 10, warmupIterations: 3)
        
    }

}

fileprivate extension Duration {
    
    var seconds: Double { Double(components.seconds) + Double(components.attoseconds) / 1e18 }
    
}

fileprivate struct RunResult {
    
    let duration: Double
    let physFootprintDelta: Double
    let residentSizeDelta: Double
    
}
