//
//  CoreDomainTests.swift
//  DatabaseBenchmarkKit
//
//  Created by Roman Antoniuk on 12.05.2026.
//

import Testing
@testable import CoreDomain

@Suite struct CoreDomainTests {
    
    @Test("Test BenchmarkedItem initialization and payload generation")
    func testItemInitialization() {
        let payloadSize = 2048
        let item = BenchmarkedItem(title: "Test", payloadSize: payloadSize)
        #expect(item.title == "Test")
        #expect(item.payload.count == payloadSize, "Payload size should exactly match the requested bytes")
    }
    
}
