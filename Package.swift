// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ChipFilterKit",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "ChipFilterKit",
            targets: ["ChipFilterKit"]
        )
    ],
    targets: [
        .target(
            name: "ChipFilterKit"
        ),
        .testTarget(
            name: "ChipFilterKitTests",
            dependencies: ["ChipFilterKit"]
        )
    ]
)
