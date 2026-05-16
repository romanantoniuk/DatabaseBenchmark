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
            FlowLayout(spacing: 8, rowSpacing: 10) {
                ForEach(availableDatabases, id: \.self) { dbName in
                    DatabaseChip(title: dbName, isSelected: settings.binding(forDatabase: dbName))
                }
            }
            .padding(.vertical, 8)
            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
        } header: {
            Text("Target Databases")
        } footer: { }
    }
    
    private var benchmarkSection: some View {
        Section {
            Picker("Items count", selection: $settings.itemsCount) {
                ForEach(BenchmarkSettings.itemOptions, id: \.self) { count in
                    Text(count.formatted())
                        .tag(count)
                }
            }
            ForEach(BenchmarkOperation.allCases) { operation in
                Toggle(operation.title, isOn: settings.binding(for: operation))
            }
            if settings.enabledOperations.contains(.concurrentInsert) {
                Stepper(
                    "Tasks: \(settings.concurrentTasks)",
                    value: $settings.concurrentTasks,
                    in: 2...50
                )
            }
        } header: {
            Text("Benchmark")
        } footer: {
            Text("Choose the operations to measure.")
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
