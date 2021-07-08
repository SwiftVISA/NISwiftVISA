// swift-tools-version:5.5

import PackageDescription

let package = Package(
	name: "NISwiftVISA",
	platforms: [.macOS(.v11)],
	products: [
		.library(
			name: "NISwiftVISA",
			targets: ["NISwiftVISA"]),
	],
	dependencies: [
		.package(url: "https://github.com/SwiftVISA/CoreSwiftVISA.git", .upToNextMinor(from: "0.1.0")),
		.package(url: "https://github.com/SwiftVISA/CVISATypes.git", .upToNextMajor(from: "1.0.0")),
		.package(
			url: "https://github.com/SwiftVISA/NISwiftVISAServiceMessages.git",
			.upToNextMinor(from: "0.1.0"))
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
