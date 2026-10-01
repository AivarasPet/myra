// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SvertoCore",
    platforms: [.iOS("26.0")],
    products: [
        .library(name: "SvertoCore", targets: ["SvertoCore"]),
    ],
    targets: [
        .binaryTarget(name: "SvertoCoreFFI", path: "Frameworks/SvertoCoreFFI.xcframework"),
        .target(
            name: "SvertoCore",
            dependencies: ["SvertoCoreFFI"],
            path: "Sources/SvertoCore",
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
    ]
)
