// swift-tools-version: 5.9
// HustleXP SwiftUI Package - Production-Ready iOS Screens

import PackageDescription

let package = Package(
    name: "HustleXP",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "HustleXP",
            targets: ["HustleXP"]
        ),
    ],
    targets: [
        .target(
            name: "HustleXP",
            path: "Sources/HustleXP"
        ),
    ]
)
