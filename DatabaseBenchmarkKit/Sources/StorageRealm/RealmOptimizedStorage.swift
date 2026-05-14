//
//  RealmOptimizedStorage.swift
//  DatabaseBenchmarkKit
//
//  Created by Roman Antoniuk on 13.05.2026.
//


import Foundation
import RealmSwift
import CoreDomain

public actor RealmOptimizedStorage: DatabaseService {
    
    nonisolated public let name = "Realm (Optimized)"
    private let config: Realm.Configuration
    private var realm: Realm!
    
    public init() {
        let fileURL = URL.documentsDirectory.appending(path: "realm_optimized_benchmark.realm")
        self.config = Realm.Configuration(
            fileURL: fileURL,
            objectTypes: [RealmItem.self]
        )
    }
    
    public func setup() async throws {
        realm = try await Realm(configuration: config, actor: self)
        realm.autorefresh = false
    }
    
    public func insert(items: [BenchmarkedItem]) async throws {
        guard !items.isEmpty else {
            return
        }
        var realmItems: [RealmItem] = []
        realmItems.reserveCapacity(items.count)
        for item in items {
            realmItems.append(RealmItem(id: item.id, title: item.title, timestamp: item.timestamp, payload: item.payload))
        }
        try await realm.asyncWrite {
            realm.add(realmItems)
        }
    }
    
    public func updateAll() async throws {
        let results = realm.objects(RealmItem.self)
        guard !results.isEmpty else {
            return
        }
        try await realm.asyncWrite {
            for item in results {
                item.title = "Updated Item"
            }
        }
    }
    
    public func fetchAll() async throws -> [BenchmarkedItem] {
        let results = realm.objects(RealmItem.self)
        var benchmarkedItems: [BenchmarkedItem] = []
        benchmarkedItems.reserveCapacity(results.count)
        for realmItem in results {
            benchmarkedItems.append(BenchmarkedItem(id: realmItem.id, title: realmItem.title, timestamp: realmItem.timestamp, payloadSize: realmItem.payload.count))
        }
        return benchmarkedItems
    }
    
    public func clearAll() async throws {
        let results = realm.objects(RealmItem.self)
        guard !results.isEmpty else {
            return
        }
        try await realm.asyncWrite {
            realm.delete(results)
        }
    }
    
}
