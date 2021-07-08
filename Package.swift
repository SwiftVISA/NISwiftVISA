// swift-tools-version:5.5

import PackageDescription

let package = Package(
	name: "NISwiftVISA",
	platforms: [.macOS("12.0")],
	products: [
		.library(
			name: "NISwiftVISA",
			targets: ["NISwiftVISA"]),
	],
	dependencies: [
		.package(url: "https://github.com/SwiftVISA/CoreSwiftVISA.git", .branch("actor")),
		.package(url: "https://github.com/SwiftVISA/CVISATypes.git", .upToNextMajor(from: "1.0.0")),
		.package(
			url: "https://github.com/SwiftVISA/NISwiftVISAServiceMessages.git", .branch("actor"))
	],
	targets: [
		.target(
			name: "NISwiftVISA",
			dependencies: ["CVISATypes", "CoreSwiftVISA", "NISwiftVISAServiceMessages"]),
		.testTarget(
			name: "NISwiftVISATests",
			dependencies: ["NISwiftVISA"]),
	]
)
