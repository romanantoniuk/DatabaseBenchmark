//
//  SwiftDataOptimizedStorage.swift
//  DatabaseBenchmarkKit
//
//  Created by Roman Antoniuk on 12.05.2026.
//

import Foundation
import SwiftData
import CoreDomain

public actor SwiftDataOptimizedStorage: DatabaseService {
    
    nonisolated public let name = "SwiftData (Optimized)"
    private var container: ModelContainer!
    
    public init() {}
    
    public func setup() async throws {
        let schema = Schema([SDItem.self])
        let config = ModelConfiguration(url: URL.documentsDirectory.appending(path: "swiftdata_benchmark.store"))
        container = try ModelContainer(for: schema, configurations: [config])
    }
    
    public func insert(items: [BenchmarkedItem]) async throws {
        guard !items.isEmpty else {
            return
        }
        let targetChunks = 10
        let calculatedSize = items.count / targetChunks
        let batchSize = max(500, min(calculatedSize, 2000))
        var index = 0
        while index < items.count {
            let end = min(index + batchSize, items.count)
            let chunk = items[index..<end]
            try autoreleasepool {
                let context = ModelContext(container)
                context.autosaveEnabled = false
                for item in chunk {
                    let sdItem = SDItem(id: item.id, title: item.title, timestamp: item.timestamp, payload: item.payload)
                    context.insert(sdItem)
                }
                try context.save()
            }
            index = end
        }
    }
    
    public func fetchAll() async throws -> [BenchmarkedItem] {
        let context = ModelContext(container)
        var descriptor = FetchDescriptor<SDItem>()
        descriptor.includePendingChanges = false
        let results = try context.fetch(descriptor)
        return results.map { sdItem in
            BenchmarkedItem(id: sdItem.id, title: sdItem.title, timestamp: sdItem.timestamp, payloadSize: sdItem.payload.count)
        }
    }
    
    public func clearAll() async throws {
        let context = ModelContext(container)
        try context.delete(model: SDItem.self)
        try context.save()
    }
    
}
