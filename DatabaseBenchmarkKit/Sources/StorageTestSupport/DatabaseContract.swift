//
//  DatabaseContract.swift
//  DatabaseBenchmarkKit
//
//  Created by Roman Antoniuk on 14.05.2026.
//

import Foundation
import Testing
import CoreDomain

public struct DatabaseContract {
    
    public static func verify(storage: any DatabaseService, expectedName: String) async throws {
        #expect(storage.name == expectedName)
        
        try await storage.setup()
        defer {
            Task { try? await storage.clearAll() }
        }
        try await storage.clearAll()
        try await storage.clearAll() // Verify idempotency
        try await storage.insert(items: [])
        try await storage.updateAll()
        #expect(try await storage.fetchAll().isEmpty)
        
        let firstID = UUID()
        let secondID = UUID()
        let timestamp = Date(timeIntervalSince1970: 400)
        let items = [
            BenchmarkedItem(id: firstID, title: "Test Item 1", timestamp: timestamp, payloadSize: 10),
            BenchmarkedItem(id: secondID, title: "Test Item 2", timestamp: timestamp.addingTimeInterval(1), payloadSize: 20)
        ]
        try await storage.insert(items: items)
        let fetchedItems = try await storage.fetchAll()
        #expect(fetchedItems.count == 2)
        
        let firstItem = try #require(fetchedItems.first(where: { $0.id == firstID }))
        let secondItem = try #require(fetchedItems.first(where: { $0.id == secondID }))
        #expect(firstItem.title == "Test Item 1")
        #expect(firstItem.timestamp == timestamp)
        #expect(firstItem.payload.count == 10)
        #expect(secondItem.title == "Test Item 2")
        #expect(secondItem.payload.count == 20)
        
        try await storage.updateAll()
        let updatedItems = try await storage.fetchAll()
        #expect(updatedItems.count == 2)
        #expect(!updatedItems.isEmpty && updatedItems.allSatisfy { $0.title == "Updated Item" })
        
        try await storage.clearAll()
        #expect(try await storage.fetchAll().isEmpty)
    }
    
}
