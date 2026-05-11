//
//  DatabaseBenchmarkTests.swift
//  DatabaseBenchmarkTests
//
//  Created by Roman Antoniuk on 11.05.2026.
//

import Testing
@testable import DatabaseBenchmark

@Suite @MainActor
struct BenchmarkViewModelTests {
    
    @Test("Test ViewModel contains all required database names")
    func testDatabaseNames() {
        let viewModel = BenchmarkViewModel()
        let expectedNames = ["Core Data", "SwiftData", "Realm", "GRDB (SQLite)"]
        #expect(viewModel.databaseNames == expectedNames, "ViewModel must support exactly 4 specific databases")
    }
    
    @Test("Test ViewModel state changes during execution")
    func testExecutionState() async {
        let viewModel = BenchmarkViewModel()
        #expect(viewModel.isRunning == false)
        #expect(viewModel.results.isEmpty == true)
    }
    
}
