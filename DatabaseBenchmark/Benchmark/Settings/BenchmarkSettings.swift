//
//  BenchmarkSettings.swift
//  DatabaseBenchmark
//
//  Created by Roman Antoniuk on 12.05.2026.
//

import SwiftUI
import MeasurementLayer

@Observable
final class BenchmarkSettings {
    
    var enabledDatabases: Set<String> = []
    
    var itemsCount = 10000
    var enableConcurrencyTest = true
    var concurrentTasks = 10
    
    var iterations = 5
    var warmupIterations = 2
    var pauseBetweenRunsMS = 100
    var memoryStrategy: MemoryStrategyOption = .peak
    var samplingIntervalMS = 5
    
    var visibleMetrics: Set<MemoryMetric> = [.physFootprint, .residentSize]
    
    var runnerConfiguration: MeasurementRunner.Configuration {
        .init(
            iterations: iterations,
            warmupIterations: warmupIterations,
            pauseBetweenRuns: .milliseconds(pauseBetweenRunsMS),
            memoryStrategy: memoryStrategy.toMeasurementStrategy(
                samplingIntervalMS: samplingIntervalMS
            )
        )
    }
    
    func binding(for metric: MemoryMetric) -> Binding<Bool> {
        Binding(
            get: {
                self.visibleMetrics.contains(metric)
            },
            set: { isEnabled in
                if isEnabled {
                    self.visibleMetrics.insert(metric)
                } else if self.visibleMetrics.count > 1 {
                    self.visibleMetrics.remove(metric)
                }
            }
        )
    }
    
    func binding(forDatabase name: String) -> Binding<Bool> {
        Binding(
            get: {
                self.enabledDatabases.contains(name)
            },
            set: { isEnabled in
                if isEnabled {
                    self.enabledDatabases.insert(name)
                } else if self.enabledDatabases.count > 1 {
                    self.enabledDatabases.remove(name)
                }
            }
        )
    }
    
    static let itemOptions = [1000, 5000, 10000, 50000, 100000]
    static let pauseOptions = [0, 50, 100, 200, 500, 1000, 2000]
    
}
