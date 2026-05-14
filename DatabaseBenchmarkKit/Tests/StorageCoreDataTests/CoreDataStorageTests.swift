//
//  CoreDataStorageTests.swift
//  DatabaseBenchmarkKit
//
//  Created by Roman Antoniuk on 12.05.2026.
//

import Foundation
import Testing
@testable import StorageCoreData
import CoreDomain
import StorageTestSupport

@Suite(.serialized)
struct SwiftDataStorageTests {
    
    struct StorageTestCase {
        let storage: any DatabaseService
        let expectedName: String
    }
    
    @Test(
        "SwiftData storage conforms to DatabaseService contract",
        arguments: [
            StorageTestCase(storage: CoreDataStorage(), expectedName: "Core Data (Standard)"),
            StorageTestCase(storage: CoreDataOptimizedStorage(), expectedName: "Core Data (Optimized)")
        ]
    )
    func testStorageContract(testCase: StorageTestCase) async throws {
        try await DatabaseContract.verify(
            storage: testCase.storage,
            expectedName: testCase.expectedName
        )
    }

}
