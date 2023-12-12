// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "LargeLanguageModels",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "LargeLanguageModels",
            targets: [
                "LargeLanguageModels"
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/PreternaturalAI/CoreGML.git", branch: "main"),
        .package(url: "https://github.com/vmanot/CorePersistence.git", branch: "main"),
        .package(url: "https://github.com/vmanot/Merge.git", branch: "master"),
        .package(url: "https://github.com/vmanot/NetworkKit.git", branch: "master"),
        .package(url: "https://github.com/vmanot/Swallow.git", branch: "master")
    ],
    targets: [
        .target(
            name: "LargeLanguageModels",
            dependencies: [
                "CorePersistence",
                "CoreGML",
                "Merge",
                "NetworkKit",
                "Swallow"
            ],
            path: "Sources/LargeLanguageModels",
            resources: [
                .process("Resources")
            ],
            swiftSettings: []
        ),
        .testTarget(
            name: "LargeLanguageModelsTests",
            dependencies: [
                "LargeLanguageModels"
            ],
            path: "Tests"
        )
    ]
)
