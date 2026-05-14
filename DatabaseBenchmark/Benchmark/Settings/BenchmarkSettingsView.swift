//
//  BenchmarkSettingsView.swift
//  DatabaseBenchmark
//
//  Created by Roman Antoniuk on 12.05.2026.
//

import SwiftUI

struct BenchmarkSettingsView: View {
    
    @Bindable var settings: BenchmarkSettings
    let availableDatabases: [String]
    
    var body: some View {
        NavigationStack {
            Form {
                databasesSection
                benchmarkSection
                runnerSection
                memorySection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Sections
    private var databasesSection: some View {
        Section {
            ForEach(availableDatabases, id: \.self) { dbName in
                Toggle(dbName, isOn: settings.binding(forDatabase: dbName))
            }
        } header: {
            Text("Target Databases")
        } footer: {
            Text("Select at least one database to run the benchmark against.")
        }
    }
    
    private var benchmarkSection: some View {
        Section {
            Picker("Items count", selection: $settings.itemsCount) {
                ForEach(BenchmarkSettings.itemOptions, id: \.self) { count in
                    Text(count.formatted())
                        .tag(count)
                }
            }
            Toggle("Concurrent test", isOn: $settings.enableConcurrencyTest)
            if settings.enableConcurrencyTest {
                Stepper(
                    "Tasks: \(settings.concurrentTasks)",
                    value: $settings.concurrentTasks,
                    in: 2...50
                )
            }
        } header: {
            Text("Benchmark")
        } footer: {
            Text("Tests concurrent writes under load.")
        }
    }
    
    private var runnerSection: some View {
        Section {
            Stepper(
                "Iterations: \(settings.iterations)",
                value: $settings.iterations,
                in: 1...20
            )
            Stepper(
                "Warmup runs: \(settings.warmupIterations)",
                value: $settings.warmupIterations,
                in: 0...5
            )
            Picker(
                "Pause between runs",
                selection: $settings.pauseBetweenRunsMS
            ) {
                ForEach(BenchmarkSettings.pauseOptions, id: \.self) { ms in
                    Text(ms.millisecondsDescription)
                        .tag(ms)
                }
            }
        } header: {
            Text("Runner")
        } footer: {
            Text("More iterations improve consistency. Warmup avoids cold-start noise.")
        }
    }
    
    private var memorySection: some View {
        Section {
            Picker("Strategy", selection: $settings.memoryStrategy) {
                ForEach(MemoryStrategyOption.allCases) { strategy in
                    Text(strategy.rawValue)
                        .tag(strategy)
                }
            }
            .pickerStyle(.segmented)
            if settings.memoryStrategy == .peak {
                Stepper(
                    "Sampling interval: \(settings.samplingIntervalMS) ms",
                    value: $settings.samplingIntervalMS,
                    in: 1...50
                )
            }
            ForEach(MemoryMetric.allCases) { metric in
                Toggle(isOn: settings.binding(for: metric)) {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(metric.rawValue)
                            Text(metric.explanation)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: metric.systemImage)
                    }
                }
            }
        } header: {
            Text("Memory")
        } footer: {
            Text(settings.memoryStrategy.helpText)
        }
    }
    
}
