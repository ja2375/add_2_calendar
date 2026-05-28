// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "add_2_calendar",
    platforms: [
        .iOS("13.0"),
    ],
    products: [
        .library(name: "add-2-calendar", targets: ["add_2_calendar"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "add_2_calendar",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: [
            ]
        )
    ]
)
