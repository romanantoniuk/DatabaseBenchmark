import Testing
@testable import Storage_CoreData
import CoreDomain

@Suite(.serialized)
struct CoreDataStorageTests {
    
    let sut = CoreDataStorage()
    
    @Test("Test Setup and Insert")
    func testInsertAndFetch() async throws {
        try await sut.setup()
        try await sut.clearAll()
        let testItems = [
            BenchmarkedItem(title: "Item 1", payloadSize: 10),
            BenchmarkedItem(title: "Item 2", payloadSize: 10)
        ]
        // Action
        try await sut.insert(items: testItems)
        let fetchedItems = try await sut.fetchAll()
        // Assert
        #expect(fetchedItems.count == 2, "Database should contain exactly 2 items after insertion")
        // Checking whether the data was saved correctly
        let firstItem = try #require(fetchedItems.first(where: { $0.title == "Item 1" }))
        #expect(firstItem.payload.count == 10)
    }
    
    @Test("Test Clear All")
    func testClearAll() async throws {
        try await sut.setup()
        // Add element
        let item = BenchmarkedItem(title: "To be deleted", payloadSize: 5)
        try await sut.insert(items: [item])
        // Remove all
        try await sut.clearAll()
        let fetchedItems = try await sut.fetchAll()
        #expect(fetchedItems.isEmpty, "Database should be empty after clearAll() is called")
    }
    
}
