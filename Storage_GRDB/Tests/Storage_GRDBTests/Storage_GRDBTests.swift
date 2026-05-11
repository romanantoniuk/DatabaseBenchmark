import Testing
@testable import Storage_GRDB
import CoreDomain

@Suite(.serialized)
struct GRDBStorageTests {
    
    let sut = GRDBStorage()
    
    @Test("Test GRDB Database integrity")
    func testDatabaseIntegrity() async throws {
        try await sut.setup()
        try await sut.clearAll()
        let item = BenchmarkedItem(title: "GRDB Fast")
        try await sut.insert(items: [item])
        let fetched = try await sut.fetchAll()
        #expect(fetched.count == 1)
    }
    
}
