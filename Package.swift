// swift-tools-version:4.0
import PackageDescription

let package = Package(
	name: "HoneyBee",
	products: [
		.library(name: "HoneyBee", targets: ["HoneyBee"])
	],
	targets: [
		.target(name: "HoneyBee"),
		.testTarget(name: "HoneyBeeTests", dependencies: ["HoneyBee"])
	]
)
