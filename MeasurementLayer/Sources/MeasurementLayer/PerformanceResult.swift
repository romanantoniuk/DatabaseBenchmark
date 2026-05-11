//
//  PerformanceResult.swift
//  MeasurementLayer
//
//  Created by Roman Antoniuk on 11.05.2026.
//

import Foundation

public struct PerformanceResult: Sendable, Identifiable {
    
    public let id = UUID()
    public let databaseName: String
    // Example "Batch Insert 10,000 items"
    public let operationName: String
    public let durationInSeconds: Double
    
    public init(databaseName: String, operationName: String, durationInSeconds: Double) {
        self.databaseName = databaseName
        self.operationName = operationName
        self.durationInSeconds = durationInSeconds
    }
    
}
