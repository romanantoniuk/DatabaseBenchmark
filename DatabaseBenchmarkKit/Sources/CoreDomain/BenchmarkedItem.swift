//
//  BenchmarkedItem.swift
//  DatabaseBenchmarkKit
//
//  Created by Roman Antoniuk on 12.05.2026.
//


import Foundation

public struct BenchmarkedItem: Codable, Sendable, Identifiable {
    
    public let id: UUID
    public let title: String
    public let timestamp: Date
    // Array of bytes to simulate the "weight" of the object
    public let payload: Data
    
    public init(id: UUID = UUID(), title: String, timestamp: Date = Date(), payloadSize: Int = 1024) {
        self.id = id
        self.title = title
        self.timestamp = timestamp
        // Create "garbage" data of the given size
        self.payload = Data(count: payloadSize)
    }
    
}
