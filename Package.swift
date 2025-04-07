// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// use local package path
let packageLocal: Bool = false

let oscaEssentialsVersion = Version("1.1.0")
let oscaTestCaseExtensionVersion = Version("1.1.0")
let oscaEventsVersion = Version("1.2.0")
let deviceKitVersion = Version("5.0.0")
let swiftDateVersion = Version("7.0.0")

let package = Package(
  name: "OSCAEventsUI",
  defaultLocalization: "de",
  platforms: [.iOS(.v15)],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "OSCAEventsUI",
      targets: ["OSCAEventsUI"]),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    // OSCAEssentials
    packageLocal ? .package(path: "../OSCAEssentials") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscaessentials-ios.git",
             .upToNextMinor(from: oscaEssentialsVersion)),
    // OSCAEvents
    packageLocal ? .package(path: "../OSCAEvents") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscaevents-ios.git",
             .upToNextMinor(from: oscaEventsVersion)),
    // OSCATestCaseExtension
    packageLocal ? .package(path: "../OSCATestCaseExtension") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscatestcaseextension-ios.git",
             .upToNextMinor(from: oscaTestCaseExtensionVersion)),
    /* SwiftDate */
    .package(url: "https://github.com/malcommac/SwiftDate.git",
             .upToNextMinor(from: swiftDateVersion)),
      /* DeviceKit */
    Package.Dependency.package(url: "https://github.com/devicekit/DeviceKit.git",
                               .upToNextMinor(from: deviceKitVersion)),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "OSCAEventsUI",
      dependencies: [/* OSCAEssentials */
                     .product(name: "OSCAEssentials",
                              package: packageLocal ? "OSCAEssentials" : "oscaessentials-ios"),
                     .product(name: "OSCAEvents",
                              package: packageLocal ? "OSCAEvents" : "oscaevents-ios")],
      path: "OSCAEventsUI/OSCAEventsUI",
      exclude:["Info.plist",
               "SupportingFiles"],
      resources: [.process("Resources")]),
    .testTarget(
      name: "OSCAEventsUITests",
      dependencies: ["OSCAEventsUI",
                     .product(name: "OSCATestCaseExtension",
                              package: packageLocal ? "OSCATestCaseExtension" : "oscatestcaseextension-ios")],
      path: "OSCAEventsUI/OSCAEventsUITests",
      exclude:["Info.plist"],
      resources: [.process("Resources")]
    ),
  ]
)
