//
//  GRDBItem.swift
//  Storage_GRDB
//
//  Created by Roman Antoniuk on 11.05.2026.
//

import Foundation
import GRDB

struct GRDBItem: Codable, FetchableRecord, PersistableRecord {
    
    let id: UUID
    let title: String
    let timestamp: Date
    let payload: Data
    
    static let databaseTableName = "benchmark_items"
    
}
