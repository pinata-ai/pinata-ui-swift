// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "PinataUI",
  platforms: [.iOS(.v15)],
  products: [
    .library(name: "PinataUI", targets: ["PinataUI"]),
  ],
  targets: [
    .target(name: "PinataUI"),
  ]
)
