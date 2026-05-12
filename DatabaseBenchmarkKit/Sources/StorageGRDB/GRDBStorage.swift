//
//  GRDBStorage.swift
//  Storage_GRDB
//
//  Created by Roman Antoniuk on 11.05.2026.
//


import Foundation
import GRDB
import CoreDomain

public actor GRDBStorage: DatabaseService {

    nonisolated public let name = "GRDB (SQLite)"
    
    private var dbQueue: DatabaseQueue!

    public init() {}

    public func setup() async throws {
        let fileURL = URL.documentsDirectory.appending(path: "grdb_benchmark.sqlite")
        dbQueue = try DatabaseQueue(path: fileURL.path)
        try await dbQueue.write { db in
            try db.create(table: GRDBItem.databaseTableName, ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("title", .text).notNull()
                t.column("timestamp", .datetime).notNull()
                t.column("payload", .blob).notNull()
            }
        }
    }

    public func insert(items: [BenchmarkedItem]) async throws {
        try await dbQueue.write { db in
            for item in items {
                let grdbItem = GRDBItem(id: item.id, title: item.title, timestamp: item.timestamp, payload: item.payload)
                try grdbItem.insert(db)
            }
        }
    }

    public func fetchAll() async throws -> [BenchmarkedItem] {
        try await dbQueue.read { db in
            let records = try GRDBItem.fetchAll(db)
            return records.map { record in
                BenchmarkedItem(id: record.id, title: record.title, timestamp: record.timestamp, payloadSize: record.payload.count) }
        }
    }

    public func clearAll() async throws {
        try await dbQueue.write { db in
            _ = try GRDBItem.deleteAll(db)
        }
    }
    
}
