//
//  BenchmarkOperation.swift
//  DatabaseBenchmark
//
//  Created by Roman Antoniuk on 15.05.2026.
//

import Foundation

enum BenchmarkOperation: CaseIterable, Identifiable, Sendable {
    
    case insert
    case fetch
    case update
    case concurrentInsert
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .insert:
            return "Insert"
        case .fetch:
            return "Fetch"
        case .update:
            return "Update"
        case .concurrentInsert:
            return "Concurrent insert"
        }
    }
    
    var summaryTitle: String {
        switch self {
        case .concurrentInsert:
            return "Concurrent"
        default:
            return title
        }
    }
    
}
