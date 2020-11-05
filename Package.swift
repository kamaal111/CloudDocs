// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CloudDocs",
    products: [
        .library(
            name: "CloudDocs",
            targets: ["CloudDocs"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CloudDocs",
            dependencies: []),
        .testTarget(
            name: "CloudDocsTests",
            dependencies: ["CloudDocs"]),
    ]
)
