// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CharacterDetailsView",
    platforms: [
        .iOS("15.0"),
        .macOS("12.0")
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CharacterDetailsView",
            targets: ["CharacterDetailsView"]),
    ],
    dependencies: [
        .package(name: "CombineExtensions", path: "../CombineExtensions"),
        .package(name: "MarvelService", path: "../MarvelService"),
        .package(name: "MarvelLocalization", path: "../MarvelLocalization"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CharacterDetailsView",
            dependencies: [
                .product(name: "CombineExtensions", package: "CombineExtensions"),
                .product(name: "MarvelLocalization", package: "MarvelLocalization"),
                .product(name: "MarvelService", package: "MarvelService"),
                .product(name: "MarvelServiceMock", package: "MarvelService"),
            ]
        ),
        .testTarget(
            name: "CharacterDetailsViewTests",
            dependencies: ["CharacterDetailsView"]),
    ]
)
