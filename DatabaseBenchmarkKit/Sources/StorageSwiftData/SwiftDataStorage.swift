//
//  SwiftDataStorage.swift
//  StorageSwiftData
//
//  Created by Roman Antoniuk on 11.05.2026.
//

import Foundation
import SwiftData
import CoreDomain

public actor SwiftDataStorage: DatabaseService {
    
    nonisolated public let name = "SwiftData (Standard)"
    private var container: ModelContainer!
    
    public init() {}

    public func setup() async throws {
        let schema = Schema([SDItem.self])
        let config = ModelConfiguration(url: URL.documentsDirectory.appending(path: "swiftdata_benchmark.store"))
        container = try ModelContainer(for: schema, configurations: [config])
    }

    public func insert(items: [BenchmarkedItem]) async throws {
        let context = ModelContext(container)
        for item in items {
            let sdItem = SDItem(
                id: item.id,
                title: item.title,
                timestamp: item.timestamp,
                payload: item.payload
            )
            context.insert(sdItem)
        }
        try context.save()
    }

    public func updateAll() async throws {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<SDItem>()
        let items = try context.fetch(descriptor)
        for item in items {
            item.title = "Updated Item"
        }
        try context.save()
    }

    public func fetchAll() async throws -> [BenchmarkedItem] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<SDItem>()
        let results = try context.fetch(descriptor)
        return results.map { sdItem in BenchmarkedItem(id: sdItem.id, title: sdItem.title, timestamp: sdItem.timestamp, payloadSize: sdItem.payload.count) }
    }

    public func clearAll() async throws {
        let context = ModelContext(container)
        try context.delete(model: SDItem.self)
        try context.save()
    }
    
}
