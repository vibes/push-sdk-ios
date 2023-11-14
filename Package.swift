// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
//===------------------------------------------------------===//
// Vibes Push SDK
//
// Copyright (c) 2022 Vibes Media LLC.
//
// See https://github.com/vibes/push-sdk-ios/
//
//===-----------------------------------------------------===//

import PackageDescription

let package = Package(
    name: "VibesPush",
    platforms: [
           .iOS(.v13),
    ],
    products: [
            .library(
                name: "VibesPush",
                targets: ["VibesPush-iOS"]
            ),
        ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        .target(
            name: "VibesPush-iOS",
            path: "Sources",
            exclude: [
           ]
        ),
        .testTarget(
            name: "VibesPushTests",
            dependencies: ["VibesPush"],
            path: "Tests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
let version = Version(4, 8, 1)
