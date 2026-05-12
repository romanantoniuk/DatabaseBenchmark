//
//  PerformanceResult.swift
//  DatabaseBenchmarkKit
//
//  Created by Roman Antoniuk on 12.05.2026.
//


import Foundation

public struct PerformanceResult: Sendable, Identifiable {
    
    public let id = UUID()
    public let databaseName: String
    public let operationName: String
    public let durationInSeconds: Double
    /// Heap + anonymous memory (matches Instruments)
    public let physFootprintDeltaMB: Double
    /// Includes mmap pages, useful for Realm
    public let residentSizeDeltaMB: Double

    public init(databaseName: String, operationName: String, durationInSeconds: Double, physFootprintDeltaMB: Double, residentSizeDeltaMB: Double) {
        self.databaseName = databaseName
        self.operationName = operationName
        self.durationInSeconds = durationInSeconds
        self.physFootprintDeltaMB = physFootprintDeltaMB
        self.residentSizeDeltaMB = residentSizeDeltaMB
    }
    
}
