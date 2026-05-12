//
//  RealmItem.swift
//  StorageRealm
//
//  Created by Roman Antoniuk on 11.05.2026.
//

import Foundation
import RealmSwift

final class RealmItem: Object {
    
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var title: String
    @Persisted var timestamp: Date
    @Persisted var payload: Data
    
    convenience init(id: UUID, title: String, timestamp: Date, payload: Data) {
        self.init()
        self.id = id
        self.title = title
        self.timestamp = timestamp
        self.payload = payload
    }
    
}
