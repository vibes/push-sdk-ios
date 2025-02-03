// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//===------------------------------------------------------===//
// Vibes Push SDK
//
// Copyright (c) 2024 Vibes Media LLC.
//
// See https://github.com/vibes/push-sdk-ios/
//
//===-----------------------------------------------------===//

import PackageDescription

let package = Package(
    name: "VibesPush",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "VibesPush",
            targets: ["VibesPush-iOS"]
        ),
    ],
    dependencies: [
        // Add external dependencies here if needed
    ],
    targets: [
        .target(
            name: "VibesPush-iOS",
            path: "Sources",
            exclude: []
        ),
        .testTarget(
            name: "VibesPushTests",
            dependencies: ["VibesPush-iOS"],
            path: "Tests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)

// Package version
let version = Version(4, 8, 1)
