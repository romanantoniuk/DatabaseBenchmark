//
//  BenchmarkViewModel.swift
//  DatabaseBenchmark
//
//  Created by Roman Antoniuk on 11.05.2026.
//


import SwiftUI
import CoreDomain
import MeasurementLayer
import Storage_CoreData
import Storage_SwiftData
import Storage_Realm
import Storage_GRDB

@Observable
@MainActor
final class BenchmarkViewModel {
    
    var results: [PerformanceResult] = []
    var isRunning = false
    
    private let runner = MeasurementRunner()
    
    private let coreDataService = CoreDataStorage()
    private let swiftDataService = SwiftDataStorage()
    private let realmService = RealmStorage()
    private let grdbService = GRDBStorage()
    
    var databaseNames: [String] {
        [coreDataService.name, swiftDataService.name, realmService.name, grdbService.name]
    }
    
    private let itemsCount = 10_000
    
    func runAllTests() async {
        guard !isRunning else { return }
        results.removeAll()
        isRunning = true
        let testItems = (0..<itemsCount).map { i in
            BenchmarkedItem(title: "Item \(i)", payloadSize: 512)
        }
        // After each test make 2 seconds break (iron rest)
        // Core Data
        await runSingleBenchmark(service: coreDataService, items: testItems)
        // SwiftData
        try? await Task.sleep(for: .seconds(2))
        await runSingleBenchmark(service: swiftDataService, items: testItems)
        // Realm
        try? await Task.sleep(for: .seconds(2))
        await runSingleBenchmark(service: realmService, items: testItems)
        // GRDB
        try? await Task.sleep(for: .seconds(2))
        await runSingleBenchmark(service: grdbService, items: testItems)
        isRunning = false
    }
    
    private func runSingleBenchmark(service: any DatabaseService, items: [BenchmarkedItem]) async {
        do {
            try await service.setup()
            // Write
            let insertRes = try await runner.runBenchmark(
                databaseName: service.name,
                operationName: "Insert \(itemsCount) items"
            ) {
                try await service.insert(items: items)
            }
            results.append(insertRes)
            // Read
            let fetchRes = try await runner.runBenchmark(
                databaseName: service.name,
                operationName: "Fetch all items"
            ) {
                _ = try await service.fetchAll()
            }
            results.append(fetchRes)
            try await service.clearAll()
        } catch {
            print("Error \(service.name): \(error)")
        }
    }
    
}
