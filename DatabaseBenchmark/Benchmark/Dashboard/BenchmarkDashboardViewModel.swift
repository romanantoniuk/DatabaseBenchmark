//
//  BenchmarkDashboardViewModel.swift
//  DatabaseBenchmark
//
//  Created by Roman Antoniuk on 11.05.2026.
//

import SwiftUI
import CoreDomain
import MeasurementLayer
import StorageCoreData
import StorageSwiftData
import StorageRealm
import StorageGRDB

@Observable
@MainActor
final class BenchmarkDashboardViewModel {
    
    var results: [PerformanceResult] = []
    var isRunning = false
    var errorMessage: String?
    var currentRunDescription: String?
    let settings = BenchmarkSettings()
    
    var hasError: Bool {
        get {
            errorMessage != nil
        }
        set {
            if !newValue {
                errorMessage = nil
            }
        }
    }
    
    var showEmptyState: Bool {
        results.isEmpty && !isRunning
    }
    
    var activeMetrics: [MemoryMetric] {
        MemoryMetric.allCases.filter {
            settings.visibleMetrics.contains($0)
        }
    }
    
    var itemsConfigText: String {
        settings.itemsCount.formatted()
    }
    var iterationsConfigText: String {
        "\(settings.iterations) (warmup: \(settings.warmupIterations))"
    }
    var memoryStrategyConfigText: String {
        settings.memoryStrategy.rawValue
    }
    
    var operationsConfigText: String {
        let names = BenchmarkOperation.allCases.compactMap { operation in
            settings.enabledOperations.contains(operation) ? operation.summaryTitle : nil
        }
        return names.isEmpty ? "None" : names.joined(separator: ", ")
    }
    
    var configurationIssues: [String] {
        var issues: [String] = []
        if settings.enabledDatabases.isEmpty {
            issues.append("Select at least one database.")
        }
        if settings.enabledOperations.isEmpty {
            issues.append("Select at least one operation.")
        }
        if settings.visibleMetrics.isEmpty {
            issues.append("Select at least one memory metric.")
        }
        return issues
    }
    
    var canRunBenchmark: Bool {
        configurationIssues.isEmpty
    }
    
    var groupedResults: [(databaseName: String, results: [PerformanceResult])] {
        databaseNames.compactMap { name in
            let dbResults = results.filter { $0.databaseName == name }
            return dbResults.isEmpty ? nil : (name, dbResults)
        }
    }
    
    private let coreData = CoreDataStorage()
    private let coreDataOptimized = CoreDataOptimizedStorage()
    private let swiftData = SwiftDataStorage()
    private let swiftDataOptimized = SwiftDataOptimizedStorage()
    private let realm = RealmStorage()
    private let realmOptimized = RealmOptimizedStorage()
    private let grdb = GRDBStorage()
    private let grdbOptimized = GRDBOptimizedStorage()
    
    private var allServices: [any DatabaseService] {
        [coreData, coreDataOptimized, swiftData, swiftDataOptimized, realm, realmOptimized, grdb, grdbOptimized]
    }
    
    var allDatabaseNames: [String] {
        allServices.map(\.name)
    }
    
    private var activeServices: [any DatabaseService] {
        allServices.filter { settings.enabledDatabases.contains($0.name) }
    }
    
    var databaseNames: [String] {
        activeServices.map(\.name)
    }
    
    init() {
        settings.enabledDatabases = Set(allDatabaseNames)
    }
    
    func runAllTests() async {
        guard !isRunning, canRunBenchmark else {
            return
        }
        isRunning = true
        errorMessage = nil
        currentRunDescription = nil
        results.removeAll()
        defer {
            currentRunDescription = nil
            isRunning = false
        }
        let runner = MeasurementRunner(configuration: settings.runnerConfiguration)
        let items = (0..<settings.itemsCount).map {
            BenchmarkedItem(title: "Item \($0)", payloadSize: 512)
        }
        for (index, service) in activeServices.enumerated() {
            if index > 0 {
                try? await Task.sleep(for: .seconds(2))
            }
            await runBenchmark(for: service, items: items, using: runner)
        }
    }
    
    private func runBenchmark(for service: any DatabaseService, items: [BenchmarkedItem], using runner: MeasurementRunner) async {
        do {
            currentRunDescription = "\(service.name) - Preparing"
            try await service.setup()
            if settings.enabledOperations.contains(.insert) {
                let operationName = "Insert \(settings.itemsCount) items"
                currentRunDescription = "\(service.name) - Insert"
                let insertResult = try await runner.runBenchmark(
                    databaseName: service.name,
                    operationName: operationName,
                    setup: {
                        try await service.clearAll()
                    },
                    teardown: {
                        try await service.clearAll()
                    }
                ) {
                    try await service.insert(items: items)
                }
                results.append(insertResult)
            }
            if settings.enabledOperations.contains(.fetch) {
                let operationName = "Fetch all items"
                currentRunDescription = "\(service.name) - Fetch"
                let fetchResult = try await runner.runBenchmark(
                    databaseName: service.name,
                    operationName: operationName,
                    setup: {
                        try await service.clearAll()
                        try await service.insert(items: items)
                    },
                    teardown: {
                        try await service.clearAll()
                    }
                ) {
                    _ = try await service.fetchAll()
                }
                results.append(fetchResult)
            }
            if settings.enabledOperations.contains(.update) {
                let operationName = "Update all items"
                currentRunDescription = "\(service.name) - Update"
                let updateResult = try await runner.runBenchmark(
                    databaseName: service.name,
                    operationName: operationName,
                    setup: {
                        try await service.clearAll()
                        try await service.insert(items: items)
                    },
                    teardown: {
                        try await service.clearAll()
                    }
                ) {
                    try await service.updateAll()
                }
                results.append(updateResult)
            }
            if settings.enabledOperations.contains(.concurrentInsert) {
                let operationName = "Concurrent Insert (\(settings.concurrentTasks) tasks)"
                currentRunDescription = "\(service.name) - Concurrent insert"
                let result = try await runner.runBenchmark(
                    databaseName: service.name,
                    operationName: operationName,
                    setup: {
                        try await service.clearAll()
                    },
                    teardown: {
                        try await service.clearAll()
                    }
                ) {
                    let taskCount = max(1, min(settings.concurrentTasks, items.count))
                    let chunkSize = (items.count + taskCount - 1) / taskCount
                    try await withThrowingTaskGroup(of: Void.self) { group in
                        var index = 0
                        for _ in 0..<taskCount {
                            let end = min(index + chunkSize, items.count)
                            let chunk = Array(items[index..<end])
                            index = end
                            group.addTask {
                                try await service.insert(items: chunk)
                            }
                            if index >= items.count {
                                break
                            }
                        }
                        try await group.waitForAll()
                    }
                }
                results.append(result)
            }
            currentRunDescription = "\(service.name) - Cleaning up"
            try? await service.clearAll()
        } catch {
            currentRunDescription = "\(service.name) - Cleaning up"
            try? await service.clearAll()
            errorMessage = "\(service.name): \(error.localizedDescription)"
        }
    }
    
}
