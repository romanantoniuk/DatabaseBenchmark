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

@Observable
@MainActor
final class BenchmarkViewModel {
    
    var results: [PerformanceResult] = []
    var isRunning = false
    
    private let runner = MeasurementRunner()
    private let coreDataService = CoreDataStorage()
    
    func runCoreDataTest() async {
        guard !isRunning else { return }
        isRunning = true
        // Generate test data (10,000 objects of 512 bytes each)
        let itemsCount = 10_000
        let items = (0..<itemsCount).map { i in
            BenchmarkedItem(title: "Item \(i)", payloadSize: 512)
        }
        do {
            // Initializing the database
            try await coreDataService.setup()
            // Testing Insert
            let insertResult = try await runner.runBenchmark(
                databaseName: coreDataService.name,
                operationName: "Insert \(itemsCount) items"
            ) {
                try await coreDataService.insert(items: items)
            }
            results.append(insertResult)
            // Testing Reading (Fetch)
            let fetchResult = try await runner.runBenchmark(
                databaseName: coreDataService.name,
                operationName: "Fetch all items"
            ) {
                _ = try await coreDataService.fetchAll()
            }
            results.append(fetchResult)
            // Cleaning the database after tests
            try await coreDataService.clearAll()
        } catch {
            print("Error testing: \(error)")
        }
        isRunning = false
    }
    
}
