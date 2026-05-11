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

@Observable
@MainActor
final class BenchmarkViewModel {
    
    var results: [PerformanceResult] = []
    var isRunning = false
    
    private let runner = MeasurementRunner()
    
    private let coreDataService = CoreDataStorage()
    private let swiftDataService = SwiftDataStorage()
    private let realmService = RealmStorage()
    
    var databaseNames: [String] {
        [coreDataService.name, swiftDataService.name, realmService.name]
    }
    
    private let itemsCount = 10_000
    
    func runAllTests() async {
        guard !isRunning else { return }
        results.removeAll()
        isRunning = true
        let testItems = (0..<itemsCount).map { i in
            BenchmarkedItem(title: "Item \(i)", payloadSize: 512)
        }
        // Core Data
        await runSingleBenchmark(service: coreDataService, items: testItems)
        // 2 second pause between tests (iron rest)
        try? await Task.sleep(for: .seconds(2))
        // SwiftData
        await runSingleBenchmark(service: swiftDataService, items: testItems)
        // 2 second pause between tests (iron rest)
        try? await Task.sleep(for: .seconds(2))
        // Realm
        await runSingleBenchmark(service: realmService, items: testItems)
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
