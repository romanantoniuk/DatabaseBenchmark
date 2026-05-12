//
//  SDItem.swift
//  StorageSwiftData
//
//  Created by Roman Antoniuk on 11.05.2026.
//

import Foundation
import SwiftData

@Model 
final class SDItem {
    
    @Attribute(.unique) var id: UUID
    var title: String
    var timestamp: Date
    var payload: Data
    
    init(id: UUID, title: String, timestamp: Date, payload: Data) {
        self.id = id
        self.title = title
        self.timestamp = timestamp
        self.payload = payload
    }
    
}
