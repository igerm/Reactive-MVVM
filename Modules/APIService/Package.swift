// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "APIService",
    platforms: [
        .iOS("13.0"),
        .macOS("10.15")
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "APIService",
            targets: ["APIService"]),
        .library(
            name: "APIServiceMock",
            targets: ["APIServiceMock"]),
    ],
    dependencies: [
        .package(name: "CombineExtensions", path: "../CombineExtensions")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "APIService",
            dependencies: ["CombineExtensions"]),
        .target(
            name: "APIServiceMock",
            dependencies: ["APIService"]),
        .testTarget(
            name: "APIServiceTests",
            dependencies: ["APIService"]),
    ]
)
