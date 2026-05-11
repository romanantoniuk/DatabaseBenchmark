// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Storage_Realm",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Storage_Realm",
            targets: ["Storage_Realm"]
        ),
    ],
    dependencies: [
        .package(name: "CoreDomain", path: "../CoreDomain"),
        .package(url: "https://github.com/realm/realm-swift.git", .upToNextMajor(from: "20.0.0"))
    ],
    targets: [
        .target(
            name: "Storage_Realm",
            dependencies: [
                .product(name: "CoreDomain", package: "CoreDomain"),
                .product(name: "RealmSwift", package: "realm-swift")
            ]
        ),
        .testTarget(
            name: "Storage_RealmTests",
            dependencies: ["Storage_Realm"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
