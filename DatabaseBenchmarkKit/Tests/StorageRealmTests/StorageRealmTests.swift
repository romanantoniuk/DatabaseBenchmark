//
//  RealmStorageTests.swift
//  DatabaseBenchmarkKit
//
//  Created by Roman Antoniuk on 12.05.2026.
//

import Foundation
import Testing
@testable import StorageRealm
import CoreDomain
import StorageTestSupport

@Suite(.serialized)
struct RealmStorageTests {
    
    struct StorageTestCase {
        let storage: any DatabaseService
        let expectedName: String
    }
    
    @Test(
        "Realm storage conforms to DatabaseService contract",
        arguments: [
            StorageTestCase(storage: RealmStorage(), expectedName: "Realm (Standard)"),
            StorageTestCase(storage: RealmOptimizedStorage(), expectedName: "Realm (Optimized)")
        ]
    )
    func testStorageContract(testCase: StorageTestCase) async throws {
        try await DatabaseContract.verify(
            storage: testCase.storage,
            expectedName: testCase.expectedName
        )
    }
    
}
