//
//  GRDBStorageTests.swift
//  DatabaseBenchmarkKit
//
//  Created by Roman Antoniuk on 12.05.2026.
//

import Foundation
import Testing
@testable import StorageGRDB
import CoreDomain
import StorageTestSupport

@Suite(.serialized)
struct GRDBStorageTests {
    
    struct StorageTestCase {
        let storage: any DatabaseService
        let expectedName: String
    }
    
    @Test(
        "GRDB storage conforms to DatabaseService contract",
        arguments: [
            StorageTestCase(storage: GRDBStorage(), expectedName: "GRDB (SQLite) (Standard)"),
            StorageTestCase(storage: GRDBOptimizedStorage(), expectedName: "GRDB (SQLite) (Optimized)")
        ]
    )
    func testStorageContract(testCase: StorageTestCase) async throws {
        try await DatabaseContract.verify(
            storage: testCase.storage,
            expectedName: testCase.expectedName
        )
    }
    
}
