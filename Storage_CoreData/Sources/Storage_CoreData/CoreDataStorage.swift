//
//  CoreDataStorage.swift
//  Storage_CoreData
//
//  Created by Roman Antoniuk on 11.05.2026.
//

import Foundation
import CoreData
import CoreDomain

public actor CoreDataStorage: DatabaseService {
    
    public let name = "Core Data"
    private var container: NSPersistentContainer!

    public init() {}

    public func setup() async throws {
        guard let modelURL = Bundle.module.url(forResource: "BenchmarkModel", withExtension: "momd"),
              let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to load Core Data model from Swift Package")
        }
        container = NSPersistentContainer(name: "BenchmarkModel", managedObjectModel: managedObjectModel)
        // Use in-memory (temporary) or file storage.
        // For the benchmark, we take a real file on disk to test the real write speed.
        let description = NSPersistentStoreDescription()
        description.url = URL.documentsDirectory.appending(path: "coredata_benchmark.sqlite")
        container.persistentStoreDescriptions = [description]
        // Load the repository asynchronously
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
        // performBackgroundTask creates a separate background thread specifically for heavy writes
        try await container.performBackgroundTask { context in
            for item in items {
                let cdItem = CDBenchmarkItem(context: context)
                cdItem.id = item.id
                cdItem.title = item.title
                cdItem.timestamp = item.timestamp
                cdItem.payload = item.payload
            }
            try context.save()
        }
    }

    public func fetchAll() async throws -> [BenchmarkedItem] {
        try await container.performBackgroundTask { context in
            let request = NSFetchRequest<CDBenchmarkItem>(entityName: "CDBenchmarkItem")
            let results = try context.fetch(request)
            // Convert the CoreData objects back to our generic Swift model
            return results.map { cdItem in
                BenchmarkedItem(
                    id: cdItem.id ?? UUID(),
                    title: cdItem.title ?? "",
                    timestamp: cdItem.timestamp ?? Date(),
                    payloadSize: cdItem.payload?.count ?? 0
                )
            }
        }
    }

    public func clearAll() async throws {
        try await container.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CDBenchmarkItem")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try context.execute(deleteRequest)
            // Clearing the context cache
            context.reset()
        }
    }
    
}
