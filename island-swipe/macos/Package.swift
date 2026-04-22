// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ActivityMonitorMac",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "ActivityMonitorMac",
            targets: ["ActivityMonitorMac"]
        )
    ],
    targets: [
        .executableTarget(
            name: "ActivityMonitorMac",
            path: "Sources/ActivityMonitorMac"
        )
    ]
)
