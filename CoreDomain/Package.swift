// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreDomain",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "CoreDomain",
            targets: ["CoreDomain"]
        ),
    ],
    targets: [
        .target(
            name: "CoreDomain"
        ),
        .testTarget(
            name: "CoreDomainTests",
            dependencies: ["CoreDomain"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
