// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DatabaseBenchmarkKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "DatabaseBenchmarkKit",
            targets: [
                "CoreDomain",
                "MeasurementLayer",
                "StorageCoreData",
                "StorageSwiftData",
                "StorageRealm",
                "StorageGRDB"
            ]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/realm/realm-swift.git",
            .upToNextMajor(from: "20.0.0")
        ),
        
        .package(
            url: "https://github.com/groue/GRDB.swift.git",
            .upToNextMajor(from: "6.29.0")
        )
    ],
    targets: [
        // MARK: - Core
        .target(
            name: "CoreDomain"
        ),
        .testTarget(
            name: "CoreDomainTests",
            dependencies: [
                "CoreDomain"
            ]
        ),
        // MARK: - Measurement
        .target(
            name: "MeasurementLayer",
            dependencies: [
                "CoreDomain"
            ]
        ),
        .testTarget(
            name: "MeasurementLayerTests",
            dependencies: [
                "MeasurementLayer"
            ]
        ),
        // MARK: - CoreData
        .target(
            name: "StorageCoreData",
            dependencies: [
                "CoreDomain"
            ]
        ),
        .testTarget(
            name: "StorageCoreDataTests",
            dependencies: [
                "StorageCoreData",
                "StorageTestSupport"
            ]
        ),
        // MARK: - SwiftData
        .target(
            name: "StorageSwiftData",
            dependencies: [
                "CoreDomain"
            ]
        ),
        .testTarget(
            name: "StorageSwiftDataTests",
            dependencies: [
                "StorageSwiftData",
                "StorageTestSupport"
            ]
        ),
        // MARK: - Realm
        .target(
            name: "StorageRealm",
            dependencies: [
                "CoreDomain",
                .product(
                    name: "RealmSwift",
                    package: "realm-swift"
                )
            ]
        ),
        .testTarget(
            name: "StorageRealmTests",
            dependencies: [
                "StorageRealm",
                "StorageTestSupport"
            ]
        ),
        // MARK: - GRDB
        .target(
            name: "StorageGRDB",
            dependencies: [
                "CoreDomain",
                .product(
                    name: "GRDB",
                    package: "GRDB.swift"
                )
            ]
        ),
        .testTarget(
            name: "StorageGRDBTests",
            dependencies: [
                "StorageGRDB",
                "StorageTestSupport"
            ]
        ),
        // MARK: - Test Support
        .target(
            name: "StorageTestSupport",
            dependencies: [
                "CoreDomain"
            ]
        )
    ],
    swiftLanguageModes: [
        .v6
    ]
)
