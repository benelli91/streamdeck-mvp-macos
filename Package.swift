// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "StreamDeckMVP",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "StreamDeckMVP", targets: ["StreamDeckMVP"])
    ],
    targets: [
        .executableTarget(name: "StreamDeckMVP"),
        .testTarget(name: "StreamDeckMVPTests", dependencies: ["StreamDeckMVP"])
    ]
)
