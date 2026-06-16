// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Boom",
    platforms: [.iOS(.v12), .macOS(.v13)],
    products: [
        .library(name: "Boom", targets: ["Boom"]),
        .library(name: "BoomObjC", targets: ["BoomObjC"]),
    ],
    targets: [
        .target(
            name: "Boom",
            dependencies: ["BoomObjC"],
            path: "Sources/Boom"
        ),
        .target(
            name: "BoomObjC",
            path: "Sources/BoomObjC",
            publicHeadersPath: "include",
        ),
        .executableTarget(
            name: "BoomCrashRunner",
            dependencies: ["Boom"],
            path: "Sources/BoomCrashRunner"
        ),
        .testTarget(
            name: "BoomTests",
            dependencies: ["Boom"],
            path: "Tests/BoomTests"
        ),
    ]
)
