// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Storage_SwiftData",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Storage_SwiftData",
            targets: ["Storage_SwiftData"]
        ),
    ],
    dependencies: [
        .package(name: "CoreDomain", path: "../CoreDomain")
    ],
    targets: [
        .target(
            name: "Storage_SwiftData",
            dependencies: [
                .product(name: "CoreDomain", package: "CoreDomain")
            ]
        ),
        .testTarget(
            name: "Storage_SwiftDataTests",
            dependencies: ["Storage_SwiftData"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
