// swift-tools-version:4.0
import PackageDescription

let package = Package(
	name: "HoneyBee",
	targets: [
		.target(name: "HoneyBee",
				dependencies: [],
				path: "HoneyBee/"),
		.testTarget(name: "HoneyBeeTests",
					dependencies: ["HoneyBee"],
					path: "HoneyBeeTests/"),
		]
)
