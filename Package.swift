// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "NISwiftVISA",
	products: [
		// Products define the executables and libraries a package produces, and make them visible to other packages.
		.library(
			name: "MachService",
			targets: ["MachService"]),
		.library(
			name: "NISwiftVISA",
			targets: ["NISwiftVISA"]),
	],
	dependencies: [
		// Dependencies declare other packages that this package depends on.
		// .package(url: /* package url */, from: "1.0.0"),
		.package(path: "~/Documents/Development/Swift/Work/VISA/CoreSwiftVISA/CoreSwiftVISA"),
		.package(path: "~/Documents/Development/Swift/Work/VISA/CVISA/CVISA"),
		.package(
			url: "https://github.com/SwiftVISA/NISwiftVISAServiceMessages.git",
			.branch("main"))
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages this package depends on.
		.target(
			name: "MachService"),
		.target(
			name: "NISwiftVISA",
			dependencies: ["MachService", "CVISA", "CoreSwiftVISA", "NISwiftVISAServiceMessages"]),
		.testTarget(
			name: "NISwiftVISATests",
			dependencies: ["NISwiftVISA"]),
	]
)