//
//  BenchmarkedItem.swift
//  DatabaseBenchmarkKit
//
//  Created by Roman Antoniuk on 12.05.2026.
//


import Foundation

public struct BenchmarkedItem: Codable, Sendable, Identifiable, Equatable {
    
    public let id: UUID
    public let title: String
    public let timestamp: Date
    public let payload: Data
    
    public init(id: UUID = UUID(), title: String, timestamp: Date = Date(), payloadSize: Int = 1024) {
        self.id = id
        self.title = title
        self.timestamp = timestamp
        self.payload = Data(count: payloadSize)
    }
    
}
