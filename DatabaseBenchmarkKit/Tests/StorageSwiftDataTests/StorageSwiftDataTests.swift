//
//  SwiftDataStorageTests.swift
//  DatabaseBenchmarkKit
//
//  Created by Roman Antoniuk on 12.05.2026.
//

import Testing
@testable import StorageSwiftData
import CoreDomain

@Suite(.serialized)
struct SwiftDataStorageTests {
    
    let sut = SwiftDataStorage()
    
    @Test("Test SwiftData Insert and Fetch")
    func testInsertAndFetch() async throws {
        try await sut.setup()
        try await sut.clearAll()
        
        let item = BenchmarkedItem(title: "SD Item", payloadSize: 10)
        try await sut.insert(items: [item])
        
        let fetched = try await sut.fetchAll()
        #expect(fetched.count == 1)
        #expect(fetched.first?.title == "SD Item")
    }
    
    @Test("Test Clear All")
    func testClearAll() async throws {
        try await sut.setup()
        // Add element
        let item = BenchmarkedItem(title: "To be deleted", payloadSize: 5)
        try await sut.insert(items: [item])
        // Remove all
        try await sut.clearAll()
        let fetchedItems = try await sut.fetchAll()
        #expect(fetchedItems.isEmpty, "Database should be empty after clearAll() is called")
    }

}
