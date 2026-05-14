//
//  DatabaseBenchmarkTests.swift
//  DatabaseBenchmarkTests
//
//  Created by Roman Antoniuk on 11.05.2026.
//

import SwiftUI
import Testing
import MeasurementLayer
@testable import DatabaseBenchmark

@Suite @MainActor
struct DatabaseBenchmarkTests {
    
    @Test("ViewModel exposes all database variants")
    func testViewModelDatabaseNames() {
        let viewModel = BenchmarkDashboardViewModel()
        
        #expect(viewModel.allDatabaseNames == [
            "Core Data (Standard)",
            "Core Data (Optimized)",
            "SwiftData (Standard)",
            "SwiftData (Optimized)",
            "Realm (Standard)",
            "Realm (Optimized)",
            "GRDB (SQLite) (Standard)",
            "GRDB (SQLite) (Optimized)"
        ])
        #expect(viewModel.databaseNames == viewModel.allDatabaseNames)
        #expect(viewModel.showEmptyState)
        #expect(!viewModel.hasError)
    }
    
    @Test("ViewModel derived display values reflect settings")
    func testViewModelDerivedValues() {
        let viewModel = BenchmarkDashboardViewModel()
        viewModel.settings.itemsCount = 50_000
        viewModel.settings.iterations = 7
        viewModel.settings.warmupIterations = 3
        viewModel.settings.memoryStrategy = .delta
        viewModel.settings.visibleMetrics = [.residentSize]
        
        #expect(viewModel.itemsConfigText == 50_000.formatted())
        #expect(viewModel.iterationsConfigText == "7 (warmup: 3)")
        #expect(viewModel.memoryStrategyConfigText == "Delta")
        #expect(viewModel.activeMetrics == [.residentSize])
    }
    
    @Test("BenchmarkSettings metric binding keeps at least one metric selected")
    func testMetricBinding() {
        let settings = BenchmarkSettings()
        let physBinding = settings.binding(for: .physFootprint)
        let residentBinding = settings.binding(for: .residentSize)
        
        #expect(physBinding.wrappedValue)
        physBinding.wrappedValue = false
        #expect(!settings.visibleMetrics.contains(.physFootprint))
        #expect(settings.visibleMetrics == [.residentSize])
        residentBinding.wrappedValue = false
        #expect(settings.visibleMetrics == [.residentSize])
        physBinding.wrappedValue = true
        #expect(settings.visibleMetrics == [.physFootprint, .residentSize])
    }
    
    @Test("BenchmarkSettings database binding keeps at least one database selected")
    func testDatabaseBinding() {
        let settings = BenchmarkSettings()
        settings.enabledDatabases = ["A", "B"]
        let aBinding = settings.binding(forDatabase: "A")
        let bBinding = settings.binding(forDatabase: "B")
        let cBinding = settings.binding(forDatabase: "C")
        
        #expect(aBinding.wrappedValue)
        aBinding.wrappedValue = false
        #expect(settings.enabledDatabases == ["B"])
        bBinding.wrappedValue = false
        #expect(settings.enabledDatabases == ["B"])
        cBinding.wrappedValue = true
        #expect(settings.enabledDatabases == ["B", "C"])
    }
    
    @Test("BenchmarkSettings creates runner configuration")
    func testRunnerConfiguration() {
        let settings = BenchmarkSettings()
        settings.iterations = 0
        settings.warmupIterations = -1
        settings.pauseBetweenRunsMS = 250
        settings.memoryStrategy = .peak
        settings.samplingIntervalMS = 12
        let configuration = settings.runnerConfiguration
        
        #expect(configuration.iterations == 1)
        #expect(configuration.warmupIterations == 0)
        #expect(configuration.pauseBetweenRuns == .milliseconds(250))
        if case .peak(let interval) = configuration.memoryStrategy {
            #expect(interval == .milliseconds(12))
        } else {
            Issue.record("Expected peak memory strategy")
        }
    }
    
    @Test("MemoryMetric exposes display metadata")
    func testMemoryMetricMetadata() {
        #expect(MemoryMetric.physFootprint.id == .physFootprint)
        #expect(MemoryMetric.physFootprint.systemImage == "memorychip")
        #expect(MemoryMetric.physFootprint.explanation == "Matches Instruments")
        #expect(MemoryMetric.residentSize.id == .residentSize)
        #expect(MemoryMetric.residentSize.systemImage == "square.3.layers.3d")
        #expect(MemoryMetric.residentSize.explanation == "Includes mmap pages")
    }
    
    @Test("MemoryStrategyOption maps UI options to measurement strategies")
    func testMemoryStrategyOptionMapping() {
        #expect(MemoryStrategyOption.delta.id == .delta)
        #expect(MemoryStrategyOption.delta.helpText == "Before/after diff. Fast but may miss spikes.")
        #expect(MemoryStrategyOption.peak.helpText == "Samples memory during execution.")
        
        if case .delta = MemoryStrategyOption.delta.toMeasurementStrategy(samplingIntervalMS: 5) {
            #expect(true)
        } else {
            Issue.record("Expected delta memory strategy")
        }
        if case .peak(let interval) = MemoryStrategyOption.peak.toMeasurementStrategy(samplingIntervalMS: 8) {
            #expect(interval == .milliseconds(8))
        } else {
            Issue.record("Expected peak memory strategy")
        }
    }
    
    @Test("PerformanceResult formatting covers duration and memory branches")
    func testPerformanceResultFormatting() {
        let fast = PerformanceResult(databaseName: "DB", operationName: "Fetch", durationInSeconds: 0.1234, physFootprintDeltaMB: 0.001, residentSizeDeltaMB: 2.5)
        let slow = PerformanceResult(databaseName: "DB", operationName: "Insert", durationInSeconds: 1.23456, physFootprintDeltaMB: 1.25, residentSizeDeltaMB: 0.001)
        
        #expect(fast.formattedDuration == "123.4 ms")
        #expect(slow.formattedDuration == "1.2346 s")
        #expect(fast.memoryValue(for: .physFootprint) == 0.001)
        #expect(fast.memoryValue(for: .residentSize) == 2.5)
        #expect(fast.formattedMemory(for: .physFootprint) == "heap: <0.01 MB")
        #expect(fast.formattedMemory(for: .residentSize) == "res: +2.50 MB")
        #expect(slow.formattedMemory(for: .physFootprint) == "heap: +1.25 MB")
        #expect(slow.formattedMemory(for: .residentSize) == "res: <0.01 MB")
    }
    
    @Test("Integer millisecond formatting covers all branches")
    func testMillisecondsDescription() {
        #expect(0.millisecondsDescription == "None")
        #expect(250.millisecondsDescription == "250 ms")
        #expect(1_000.millisecondsDescription == "1 s")
        #expect(2_500.millisecondsDescription == "2 s")
    }
    
}
