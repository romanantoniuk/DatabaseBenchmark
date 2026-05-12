//
//  RealmStorage.swift
//  StorageRealm
//
//  Created by Roman Antoniuk on 11.05.2026.
//

import Foundation
import RealmSwift
import CoreDomain

public actor RealmStorage: DatabaseService {
    
    nonisolated public let name = "Realm"
    private let config: Realm.Configuration
    
    public init() {
        let fileURL = URL.documentsDirectory.appending(path: "realm_benchmark.realm")
        self.config = Realm.Configuration(fileURL: fileURL)
    }

    public func setup() async throws {
        try await Task.detached {
            _ = try Realm(configuration: self.config)
        }.value
    }

    public func insert(items: [BenchmarkedItem]) async throws {
        try await Task.detached {
            let realm = try Realm(configuration: self.config)
            try realm.write {
                for item in items {
                    let realmItem = RealmItem(id: item.id, title: item.title, timestamp: item.timestamp, payload: item.payload)
                    realm.add(realmItem)
                }
            }
        }.value
    }

    public func fetchAll() async throws -> [BenchmarkedItem] {
        try await Task.detached {
            let realm = try Realm(configuration: self.config)
            let results = realm.objects(RealmItem.self)
            return Array(results).map { realmItem in BenchmarkedItem(id: realmItem.id, title: realmItem.title, timestamp: realmItem.timestamp, payloadSize: realmItem.payload.count) }
        }.value
    }

    public func clearAll() async throws {
        try await Task.detached {
            let realm = try Realm(configuration: self.config)
            try realm.write {
                realm.deleteAll()
            }
        }.value
    }
    
}
