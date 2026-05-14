//
//  MeasurementLayerTests.swift
//  DatabaseBenchmarkKit
//
//  Created by Roman Antoniuk on 12.05.2026.
//

import Foundation
import Testing
@testable import MeasurementLayer

@Suite struct MeasurementLayerTests {
    
    @Test("MeasurementRunner captures delta execution")
    func testRunnerExecutionWithDeltaStrategy() async throws {
        let configuration = MeasurementRunner.Configuration(
            iterations: 1,
            warmupIterations: 0,
            pauseBetweenRuns: .zero,
            memoryStrategy: .delta
        )
        let runner = MeasurementRunner(configuration: configuration)
        let result = try await runner.runBenchmark(databaseName: "MockDB", operationName: "MockOp") {
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(result.databaseName == "MockDB")
        #expect(result.operationName == "MockOp")
        #expect(result.durationInSeconds > 0)
        #expect(result.physFootprintDeltaMB >= 0)
        #expect(result.residentSizeDeltaMB >= 0)
    }
    
    @Test("MeasurementRunner captures peak execution")
    func testRunnerExecutionWithPeakStrategy() async throws {
        let configuration = MeasurementRunner.Configuration(
            iterations: 1,
            warmupIterations: 0,
            pauseBetweenRuns: .zero,
            memoryStrategy: .peak(samplingInterval: .milliseconds(1))
        )
        let runner = MeasurementRunner(configuration: configuration)
        let result = try await runner.runBenchmark(databaseName: "MockDB", operationName: "PeakOp") {
            var data = Data(count: 64 * 1_024)
            _ = data.withUnsafeMutableBytes { buffer in
                buffer.initializeMemory(as: UInt8.self, repeating: 1)
            }
            try await Task.sleep(for: .milliseconds(5))
            _ = data.count
        }
        #expect(result.databaseName == "MockDB")
        #expect(result.operationName == "PeakOp")
        #expect(result.durationInSeconds > 0)
        #expect(result.physFootprintDeltaMB >= 0)
        #expect(result.residentSizeDeltaMB >= 0)
    }
    
    @Test("MeasurementRunner executes setup, warmup, iterations, and teardown")
    func testSetupWarmupAndTeardownExecutionCounts() async throws {
        let configuration = MeasurementRunner.Configuration(
            iterations: 3,
            warmupIterations: 2,
            pauseBetweenRuns: .zero,
            memoryStrategy: .delta
        )
        let runner = MeasurementRunner(configuration: configuration)
        let counter = BenchmarkCounter()
        _ = try await runner.runBenchmark(
            databaseName: "MockDB",
            operationName: "CountedOp",
            setup: {
                await counter.incrementSetup()
            },
            teardown: {
                await counter.incrementTeardown()
            }
        ) {
            await counter.incrementOperation()
        }
        let counts = await counter.counts
        #expect(counts.setup == 5)
        #expect(counts.operation == 5)
        #expect(counts.teardown == 5)
    }
    
    @Test("MeasurementRunner propagates operation errors")
    func testOperationErrorPropagation() async throws {
        struct ExpectedError: Error {}
        let runner = MeasurementRunner(
            configuration: .init(iterations: 1, warmupIterations: 0, pauseBetweenRuns: .zero, memoryStrategy: .peak(samplingInterval: .milliseconds(1)))
        )
        await #expect(throws: ExpectedError.self) {
            try await runner.runBenchmark(databaseName: "MockDB", operationName: "FailingOp") {
                throw ExpectedError()
            }
        }
    }
    
    @Test("MeasurementRunner configuration normalizes invalid counts")
    func testConfigurationNormalization() {
        let configuration = MeasurementRunner.Configuration(iterations: 0, warmupIterations: -3)
        #expect(configuration.iterations == 1)
        #expect(configuration.warmupIterations == 0)
        #expect(MeasurementRunner.Configuration.quick.iterations == 3)
        #expect(MeasurementRunner.Configuration.precise.iterations == 10)
    }
    
    @Test("MemorySnapshot clamps negative deltas")
    func testMemorySnapshotDelta() {
        let baseline = MemorySnapshot(physFootprint: 10, residentSize: 20)
        let increased = MemorySnapshot(physFootprint: 12.5, residentSize: 23.25).delta(from: baseline)
        let decreased = MemorySnapshot(physFootprint: 5, residentSize: 7).delta(from: baseline)
        #expect(increased.physFootprint == 2.5)
        #expect(increased.residentSize == 3.25)
        #expect(decreased.physFootprint == 0)
        #expect(decreased.residentSize == 0)
        #expect(MemorySnapshot.current().physFootprint >= 0)
        #expect(MemorySnapshot.current().residentSize >= 0)
    }
    
    @Test("PerformanceResult stores values and unique identity")
    func testPerformanceResultInitialization() {
        let first = PerformanceResult(databaseName: "DB", operationName: "Insert", durationInSeconds: 1.2, physFootprintDeltaMB: 3.4, residentSizeDeltaMB: 5.6)
        let second = PerformanceResult(databaseName: "DB", operationName: "Insert", durationInSeconds: 1.2, physFootprintDeltaMB: 3.4, residentSizeDeltaMB: 5.6)
        #expect(first.databaseName == "DB")
        #expect(first.operationName == "Insert")
        #expect(first.durationInSeconds == 1.2)
        #expect(first.physFootprintDeltaMB == 3.4)
        #expect(first.residentSizeDeltaMB == 5.6)
        #expect(first.id != second.id)
    }
    
}

private actor BenchmarkCounter {
    
    private var setupCount = 0
    private var operationCount = 0
    private var teardownCount = 0
    
    var counts: (setup: Int, operation: Int, teardown: Int) {
        (setupCount, operationCount, teardownCount)
    }
    
    func incrementSetup() {
        setupCount += 1
    }
    
    func incrementOperation() {
        operationCount += 1
    }
    
    func incrementTeardown() {
        teardownCount += 1
    }
    
}

