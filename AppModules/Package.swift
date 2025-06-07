// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "AppModules",
    platforms: [.iOS("17.0"), .macOS("14.0")],
    products: [
        .library(name: "Gallery", targets: ["Gallery"]),
        .library(name: "Home", targets: ["Home"]),
        .library(name: "Restaurants", targets: ["Restaurants"]),
        .library(name: "Rides", targets: ["Rides"]),
        .library(name: "ViewModifiers", targets: ["ViewModifiers"]) ],
    dependencies: [
        .package(name: "UDF", path: "../UDF"),
        .package(name: "SharedModules", path: "../SharedModules"),
        .package(url: "git@github.com/gonzalezreal/swift-markdown-ui.git",
                 from: "2.3.0") ],
    targets: [
        .target(name: "Gallery",
                dependencies: [
                    .product(name: "ASKeys", package: "SharedModules"),
                    .product(name: "Cache", package: "SharedModules"),
                    .product(name: "Downloader", package: "SharedModules"),
                    "UDF",
                    "ViewModifiers",
                    .product(name: "MarkdownUI", package: "swift-markdown-ui") ],
                resources: [.copy("gallery.json")]),
        .testTarget(name: "GalleryTests",
                    dependencies: ["Gallery"],
                    resources: [.copy("testgallery.json")]),

        .target(name: "Home",
                dependencies: [
                    .product(name: "Schedule", package: "SharedModules"),
                    "UDF",
                    "ViewModifiers" ],
                resources: [.process("Assets.xcassets")]),

        .target(name: "Restaurants",
                dependencies: [
                    .product(name: "ASKeys", package: "SharedModules"),
                    .product(name: "Cache", package: "SharedModules"),
                    .product(name: "Schedule", package: "SharedModules"),
                    "UDF",
                    "ViewModifiers" ]),

        .target(name: "Rides",
                dependencies: [
                    .product(name: "Cache", package: "SharedModules"),
                    .product(name: "Downloader", package: "SharedModules"),
                    "Restaurants",
                    "UDF",
                    "ViewModifiers" ]),

        .target(name: "ViewModifiers")
    ]
)
