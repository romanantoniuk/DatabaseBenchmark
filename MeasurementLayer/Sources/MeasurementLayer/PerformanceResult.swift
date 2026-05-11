import Foundation

public struct PerformanceResult: Sendable, Identifiable {
    public let id = UUID()
    public let databaseName: String
    public let operationName: String // Напр. "Batch Insert 10,000 items"
    public let durationInSeconds: Double
    
    public init(databaseName: String, operationName: String, durationInSeconds: Double) {
        self.databaseName = databaseName
        self.operationName = operationName
        self.durationInSeconds = durationInSeconds
    }
}