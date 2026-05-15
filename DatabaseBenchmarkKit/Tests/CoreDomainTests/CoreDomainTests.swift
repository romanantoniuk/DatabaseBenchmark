//
//  CoreDomainTests.swift
//  DatabaseBenchmarkKit
//
//  Created by Roman Antoniuk on 12.05.2026.
//

import Foundation
import Testing
@testable import CoreDomain

@Suite struct CoreDomainTests {
    
    @Test("BenchmarkedItem preserves initializer values")
    func testItemInitialization() {
        let id = UUID()
        let timestamp = Date(timeIntervalSince1970: 1_234)
        let payloadSize = 2_048
        let item = BenchmarkedItem(id: id, title: "Test", timestamp: timestamp, payloadSize: payloadSize)
        #expect(item.id == id)
        #expect(item.title == "Test")
        #expect(item.timestamp == timestamp)
        #expect(item.payload.count == payloadSize)
    }

    @Test("BenchmarkedItem preserves payload bytes")
    func testPayloadInitialization() {
        let payload = Data([3, 1, 4, 1, 5, 9])
        let item = BenchmarkedItem(title: "Payload", payload: payload)
        #expect(item.payload == payload)
    }
    
    @Test("BenchmarkedItem supports empty payloads")
    func testEmptyPayload() {
        let item = BenchmarkedItem(title: "Empty", payloadSize: 0)
        #expect(item.payload.isEmpty)
    }
    
    @Test("BenchmarkedItem is Codable")
    func testCodableRoundTrip() throws {
        let item = BenchmarkedItem(title: "Codable", payloadSize: 16)
        let data = try JSONEncoder().encode(item)
        let decoded = try JSONDecoder().decode(BenchmarkedItem.self, from: data)
        #expect(decoded == item)
    }
    
}
