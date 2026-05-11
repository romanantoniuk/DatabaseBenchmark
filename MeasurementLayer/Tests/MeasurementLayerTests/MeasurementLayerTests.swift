import Testing
@testable import MeasurementLayer

@Suite struct MeasurementLayerTests {
    
    @Test("Test MeasurementRunner successfully captures execution")
    func testRunnerExecution() async throws {
        let runner = MeasurementRunner()
        let result = try await runner.runBenchmark(databaseName: "MockDB", operationName: "MockOp") {
            try await Task.sleep(for: .milliseconds(50))
        }
        #expect(result.databaseName == "MockDB")
        #expect(result.operationName == "MockOp")
        #expect(result.durationInSeconds > 0, "Duration should be greater than zero")
        #expect(result.memoryUsedInMegabytes >= 0, "Memory usage cannot be negative")
    }
    
}
