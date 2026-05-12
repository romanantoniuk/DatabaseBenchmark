//
//  DatabaseService.swift
//  DatabaseBenchmarkKit
//
//  Created by Roman Antoniuk on 12.05.2026.
//


import Foundation

public protocol DatabaseService: Sendable {
    
    /// Unique database name to display in the UI (e.g. "Realm", "CoreData")
    var name: String { get }
    
    /// Preparing the database (creating tables, etc.)
    func setup() async throws
    
    /// Writing an array of objects
    func insert(items: [BenchmarkedItem]) async throws
    
    /// Reading all objects
    func fetchAll() async throws -> [BenchmarkedItem]
    
    /// Complete database cleanup
    func clearAll() async throws
    
}
