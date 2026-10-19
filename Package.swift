// swift-tools-version: 5.9
import PackageDescription
let package = Package(name: "SidebandCore", platforms: [.iOS(.v17), .macOS(.v13)], products: [.library(name: "SidebandCore", targets: ["SidebandCore"])], targets: [.target(name: "SidebandCore"), .testTarget(name: "SidebandCoreTests", dependencies: ["SidebandCore"])])
