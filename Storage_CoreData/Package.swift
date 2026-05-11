// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Storage_CoreData",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Storage_CoreData",
            targets: ["Storage_CoreData"]
        ),
    ],
    dependencies: [
        .package(name: "CoreDomain", path: "../CoreDomain")
    ],
    targets: [
        .target(
            name: "Storage_CoreData",
            dependencies: [
                .product(name: "CoreDomain", package: "CoreDomain")
            ]
        ),
        .testTarget(
            name: "Storage_CoreDataTests",
            dependencies: ["Storage_CoreData"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
