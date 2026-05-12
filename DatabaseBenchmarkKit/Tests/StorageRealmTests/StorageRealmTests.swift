//
//  RealmStorageTests.swift
//  DatabaseBenchmarkKit
//
//  Created by Roman Antoniuk on 12.05.2026.
//

import Testing
@testable import StorageRealm
import CoreDomain

@Suite(.serialized)
struct RealmStorageTests {
    
    let sut = RealmStorage()
    
    @Test("Test Realm Insert and Clear")
    func testInsertAndClear() async throws {
        try await sut.setup()
        try await sut.clearAll()
        let items = [BenchmarkedItem(title: "Realm 1"), BenchmarkedItem(title: "Realm 2")]
        try await sut.insert(items: items)
        let fetchedAfterInsert = try await sut.fetchAll()
        #expect(fetchedAfterInsert.count == 2)
        try await sut.clearAll()
        let fetchedAfterClear = try await sut.fetchAll()
        #expect(fetchedAfterClear.isEmpty)
    }
    
}
