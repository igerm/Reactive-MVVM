// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MarvelService",
    platforms: [
        .iOS("15.0"),
        .macOS("12.0")
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MarvelService",
            targets: ["MarvelService"]),
        .library(
            name: "MarvelServiceMock",
            targets: ["MarvelServiceMock"]),
    ],
    dependencies: [
        .package(name: "APIService", path: "../APIService"),
        .package(name: "CombineExtensions", path: "../CombineExtensions"),
        .package(name: "CoreDataService", path: "../CoreDataService"),
        .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", from: "6.6.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MarvelService",
            dependencies: [
                .product(name: "APIService", package: "APIService"),
                .product(name: "CombineExtensions", package: "CombineExtensions"),
                .product(name: "CoreDataService", package: "CoreDataService"),
            ],
            resources: [
                .process("Resources/"),
            ]
        ),
        .target(
            name: "MarvelServiceMock",
            dependencies: ["MarvelService"]
        ),
        .testTarget(
            name: "MarvelServiceTests",
            dependencies: [
                .product(name: "APIServiceMock", package: "APIService"),
                .product(name: "CoreDataService", package: "CoreDataService"),
                "MarvelService",
            ],
            resources: [
                .process("Files/")
            ],
            plugins: [
                .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin"),
            ]
        ),
    ]
)
