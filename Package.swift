// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ICloudDocs",
    products: [
        .library(
            name: "ICloudDocs",
            targets: ["ICloudDocs"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ICloudDocs",
            dependencies: []),
        .testTarget(
            name: "ICloudDocsTests",
            dependencies: ["ICloudDocs"]),
    ]
)
