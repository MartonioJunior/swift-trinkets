// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

// MARK: - Utilities
public enum UpcomingFeatures: String, CaseIterable {
    case existentialAny
    case immutableWeakCaptures
    case inferIsolatedConformances
    case internalImportsByDefault
    case memberImportVisibility
    case nonisolatedNonsendingByDefault
    case strictMemorySafety

    var asSetting: SwiftSetting { .enableUpcomingFeature(rawValue.capitalized) }
}

public enum ExperimentalFeatures: String, CaseIterable {
    case fullTypedThrows
    case keyPathWithMethodMembers

    var asSetting: SwiftSetting { .enableExperimentalFeature(rawValue.capitalized) }
}

public extension Array where Element == SwiftSetting {
    static var allFeatures: Self { .experimentalFeatures + .upcomingFeatures }
    static var experimentalFeatures: Self { ExperimentalFeatures.allCases.map(\.asSetting) }
    static var upcomingFeatures: Self { UpcomingFeatures.allCases.map(\.asSetting) }
}

func lib(_ name: String, targets: String...) -> Product {
    .library(name: name, targets: targets)
}

func platformDeps(_ platforms: SupportedPlatform...) -> [SupportedPlatform] {
    platforms
}

func targetDep(name: String, package: String, condition: TargetDependencyCondition? = nil) -> Target.Dependency {
    .product(name: name, package: package, condition: condition)
}

// MARK: - Traits
var traits: Set<Trait> = [
    .trait(name: "LocalizedSymbols", description: "Adds in support for String Catalogs")
]

// MARK: - Dependencies
let casePaths = targetDep(name: "CasePaths", package: "swift-case-paths")
let customDump = targetDep(name: "CustomDump", package: "swift-custom-dump")
let identifiedCollections = targetDep(name: "IdentifiedCollections", package: "swift-identified-collections")
let mathe = targetDep(name: "Mathe", package: "Mathe")
let minimal = targetDep(name: "Minimal", package: "Minimal")
let numerics = targetDep(name: "Numerics", package: "swift-numerics")
let tagged = targetDep(name: "Tagged", package: "swift-tagged")
let variety = targetDep(name: "SwiftVariety", package: "swift-variety")

let dependencies: [Package.Dependency] = [
    .package(url: "https://github.com/pointfreeco/swift-case-paths", .upToNextMajor(from: "1.7.0")),
    .package(url: "https://github.com/pointfreeco/swift-custom-dump", .upToNextMajor(from: "1.7.3")),
    .package(url: "https://github.com/pointfreeco/swift-identified-collections", .upToNextMajor(from: "1.1.1")),
    .package(url: "https://github.com/pointfreeco/swift-tagged", .upToNextMajor(from: "0.10.0")),
    .package(url: "https://github.com/apple/swift-numerics", .upToNextMajor(from: "1.1.0")),
    .package(url: "https://github.com/MartonioJunior/Mathe", .upToNextMajor(from: "0.1.2"), traits: ["Numerics"]),
    .package(url: "https://github.com/MartonioJunior/Minimal", .upToNextMajor(from: "0.1.1")),
    .package(url: "https://github.com/MartonioJunior/swift-variety", .upToNextMajor(from: "0.1.1")),
    .package(url: "https://github.com/swiftlang/swift-docc-plugin", .upToNextMajor(from: "1.4.5"))
]

// MARK: - Targets
var targets: [Target] = [
    .target(
        name: "Activities",
        swiftSettings: .allFeatures
    ),
    .target(
        name: "Collectables",
        dependencies: [identifiedCollections, variety],
        swiftSettings: .allFeatures
    ),
    .target(
        name: "Custom",
        swiftSettings: .allFeatures
    ),
    .target(
        name: "Exchanges",
        dependencies: ["Custom", "Inventory"],
        swiftSettings: .allFeatures
    ),
    .target(
        name: "Flow",
        dependencies: [mathe, minimal],
        swiftSettings: .allFeatures
    ),
    .target(
        name: "Inventory",
        dependencies: ["TrinketsUnits"],
        swiftSettings: .allFeatures
    ),
    .target(
        name: "Matches",
        swiftSettings: .allFeatures
    ),
    .target(
        name: "Notation",
        swiftSettings: .allFeatures
    ),
    .target(
        name: "Progression",
        dependencies: ["Custom", "Flow", minimal],
        swiftSettings: .allFeatures
    ),
    .target(
        name: "Quests",
        swiftSettings: .allFeatures
    ),
    .target(
        name: "SI",
        dependencies: ["TrinketsUnits", tagged],
        resources: [.process("Localization/")],
        swiftSettings: .allFeatures
    ),
    .target(
        name: "Tabletop",
        swiftSettings: .allFeatures
    ),
    .target(
        name: "TrinketsUnits",
        dependencies: ["Notation", numerics, tagged],
        resources: [.process("Localization/")],
        swiftSettings: .allFeatures
    )
]

targets.append(
    .target(
        name: "Trinkets",
        dependencies: targets.map { Target.Dependency(stringLiteral: $0.name) },
        swiftSettings: .allFeatures
    )
)

let testTargets: [Target] = targets.map {
    .testTarget(
        name: "\($0.name)Tests",
        dependencies: $0.dependencies + [
            Target.Dependency(stringLiteral: $0.name),
            customDump
        ]
    )
}

targets.append(
    .target(
        name: "SM64Trinkets",
        dependencies: ["Collectables", "Custom", "Trinkets"],
        path: "Examples/SM64"
    )
)

// MARK: - Products
let products: [Product] = [
    .library(
        name: "Trinkets",
        targets: targets.map(\.name)
    ),
    .library(
        name: "UnitSI",
        targets: ["TrinketsUnits", "SI"]
    )
]

// MARK: - Supported Platforms
let supportedPlatforms: [SupportedPlatform] = [
    .macOS(.v13)
]

// MARK: PackageDescription
let package = Package(
    name: "Trinkets",
    defaultLocalization: "en",
    platforms: supportedPlatforms,
    products: products,
    traits: traits,
    dependencies: dependencies,
    targets: targets + testTargets,
    swiftLanguageModes: [.v6]
)
