// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VirgilSDK",
    platforms: [
        .macOS(.v10_11), .iOS(.v9), .tvOS(.v9), .watchOS(.v2)
    ],
    products: [
        .library(
            name: "VirgilSDK",
            targets: ["VirgilSDK"])
    ],

    dependencies: [
        .package(url: "https://github.com/VirgilSecurity/virgil-crypto-x.git",
                 Range(uncheckedBounds: (lower: Version(6, 0, 1), upper: Version(7, 0, 0))))
    ],

    targets: [
        .target(
            name: "VirgilSDK",
            dependencies: [
                .product(name: "VirgilCrypto", package: "virgil-crypto-x")
            ],
            path: "Source"
        ),
        .testTarget(
            name: "VirgilSDKTests",
            dependencies: ["VirgilSDK"],
            path: "Tests/Swift",
            resources: [
                .process("Data/Keyknox.json"),
                .process("Data/Cards.json"),
                .process("Data/TestConfig.plist")
            ],
            swiftSettings: [
                .define("SPM_BUILD")
            ]
        )
    ]
)
