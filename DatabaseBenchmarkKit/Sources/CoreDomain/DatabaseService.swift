//
//  DatabaseService.swift
//  DatabaseBenchmarkKit
//
//  Created by Roman Antoniuk on 12.05.2026.
//


import Foundation

public protocol DatabaseService: Sendable {
    
    var name: String { get }
    
    func setup() async throws
    func insert(items: [BenchmarkedItem]) async throws
    func updateAll() async throws
    func fetchAll() async throws -> [BenchmarkedItem]
    func clearAll() async throws
    
}
