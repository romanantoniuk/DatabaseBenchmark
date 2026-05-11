// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MeasurementLayer",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "MeasurementLayer",
            targets: ["MeasurementLayer"]
        ),
    ],
    dependencies: [
        .package(name: "CoreDomain", path: "../CoreDomain")
    ],
    targets: [
        .target(
            name: "MeasurementLayer",
            dependencies: [
                .product(name: "CoreDomain", package: "CoreDomain")
            ]
        ),
        .testTarget(
            name: "MeasurementLayerTests",
            dependencies: ["MeasurementLayer"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
