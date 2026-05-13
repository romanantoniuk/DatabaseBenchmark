//
//  GRDBOptimizedStorage.swift
//  DatabaseBenchmarkKit
//
//  Created by Roman Antoniuk on 13.05.2026.
//

import Foundation
import GRDB
import CoreDomain

public actor GRDBOptimizedStorage: DatabaseService {

    nonisolated public let name = "GRDB (SQLite) (Optimized)"
    
    private var dbPool: DatabasePool!

    public init() {}

    public func setup() async throws {
        let fileURL = URL.documentsDirectory.appending(path: "grdb_optimized_benchmark.sqlite")
        var configuration = Configuration()
        configuration.prepareDatabase { db in
            try db.execute(sql: "PRAGMA journal_mode = WAL")
            try db.execute(sql: "PRAGMA synchronous = NORMAL")
            try db.execute(sql: "PRAGMA temp_store = MEMORY")
        }
        dbPool = try DatabasePool(path: fileURL.path, configuration: configuration)
        try await dbPool.write { db in
            try db.create(table: GRDBItem.databaseTableName, ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("title", .text).notNull()
                t.column("timestamp", .datetime).notNull()
                t.column("payload", .blob).notNull()
            }
        }
    }

    public func insert(items: [BenchmarkedItem]) async throws {
        guard !items.isEmpty else {
            return
        }
        try await dbPool.write { db in
            try db.inTransaction {
                let statement = try db.cachedStatement(sql: "INSERT INTO benchmark_items (id, title, timestamp, payload) VALUES (?, ?, ?, ?)")
                for item in items {
                    try statement.execute(arguments: [
                        item.id.uuidString,
                        item.title,
                        item.timestamp,
                        item.payload
                    ])
                }
                return .commit
            }
        }
    }

    public func fetchAll() async throws -> [BenchmarkedItem] {
        try await dbPool.read { db in
            let rows = try Row.fetchCursor(db, sql: "SELECT id, title, timestamp, payload FROM benchmark_items")
            var items: [BenchmarkedItem] = []
            while let row = try rows.next() {
                let idString: String = row["id"]
                let title: String = row["title"]
                let timestamp: Date = row["timestamp"]
                let payload: Data = row["payload"]
                items.append(BenchmarkedItem(id: UUID(uuidString: idString) ?? UUID(), title: title, timestamp: timestamp, payloadSize: payload.count))
            }
            return items
        }
    }

    public func clearAll() async throws {
        try await dbPool.write { db in
            try db.execute(sql: "DELETE FROM benchmark_items")
        }
    }
    
}
