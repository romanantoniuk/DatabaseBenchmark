// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Storage_GRDB",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Storage_GRDB",
            targets: ["Storage_GRDB"]
        ),
    ],
    dependencies: [
        .package(name: "CoreDomain", path: "../CoreDomain"),
        .package(url: "https://github.com/groue/GRDB.swift.git", .upToNextMajor(from: "6.29.0"))
    ],
    targets: [
        .target(
            name: "Storage_GRDB",
            dependencies: [
                .product(name: "CoreDomain", package: "CoreDomain"),
                .product(name: "GRDB", package: "GRDB.swift")
            ]
        ),
        .testTarget(
            name: "Storage_GRDBTests",
            dependencies: ["Storage_GRDB"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
