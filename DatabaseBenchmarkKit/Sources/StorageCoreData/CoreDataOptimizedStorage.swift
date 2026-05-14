//
//  CoreDataOptimizedStorage.swift
//  DatabaseBenchmarkKit
//
//  Created by Roman Antoniuk on 13.05.2026.
//

import Foundation
import CoreData
import CoreDomain

public actor CoreDataOptimizedStorage: DatabaseService {
    
    nonisolated public let name = "Core Data (Optimized)"
    private var container: NSPersistentContainer!

    public init() {}

    public func setup() async throws {
        guard let modelURL = Bundle.module.url(forResource: "BenchmarkModel", withExtension: "momd"),
              let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to load Core Data model from Swift Package")
        }
        container = NSPersistentContainer(name: "BenchmarkModel", managedObjectModel: managedObjectModel)
        let description = NSPersistentStoreDescription()
        description.url = URL.documentsDirectory.appending(path: "coredata_benchmark.sqlite")
        container.persistentStoreDescriptions = [description]
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            container.loadPersistentStores { _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    public func insert(items: [BenchmarkedItem]) async throws {
        guard !items.isEmpty else {
            return
        }
        try await container.performBackgroundTask { context in
            var index = 0
            let batchInsert = NSBatchInsertRequest(entityName: "CDBenchmarkItem", dictionaryHandler: { dictionary in
                guard index < items.count else {
                    return true
                }
                let item = items[index]
                dictionary.addEntries(from: [
                    "id": item.id,
                    "title": item.title,
                    "timestamp": item.timestamp,
                    "payload": item.payload
                ])
                index += 1
                return false
            })
            try context.execute(batchInsert)
        }
    }

    public func updateAll() async throws {
        try await container.performBackgroundTask { context in
            let batchUpdate = NSBatchUpdateRequest(entityName: "CDBenchmarkItem")
            batchUpdate.propertiesToUpdate = ["title": "Updated Item"]
            batchUpdate.resultType = .statusOnlyResultType
            try context.execute(batchUpdate)
            context.reset()
        }
    }

    public func fetchAll() async throws -> [BenchmarkedItem] {
        try await container.performBackgroundTask { context in
            let request = NSFetchRequest<CDBenchmarkItem>(entityName: "CDBenchmarkItem")
            request.includesPendingChanges = false
            request.fetchBatchSize = 1000
            let results = try context.fetch(request)
            var benchmarkedItems: [BenchmarkedItem] = []
            benchmarkedItems.reserveCapacity(results.count)
            for cdItem in results {
                autoreleasepool {
                    benchmarkedItems.append(BenchmarkedItem(id: cdItem.id ?? UUID(), title: cdItem.title ?? "", timestamp: cdItem.timestamp ?? Date(), payloadSize: cdItem.payload?.count ?? 0))
                }
            }
            return benchmarkedItems
        }
    }

    public func clearAll() async throws {
        try await container.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CDBenchmarkItem")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try context.execute(deleteRequest)
            context.reset()
        }
    }
    
}
