// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "SharedModules",
    platforms: [.iOS("17.0"), .macOS("14.0")],
    products: [
        .library(name: "ASKeys", targets: ["ASKeys"]),
        .library(name: "Cache", targets: ["Cache"]),
        .library(name: "Downloader", targets: ["Downloader"]),
        .library(name: "Schedule", targets: ["Schedule"])
    ],
    dependencies: [
        .package(name: "UDF", path: "../UDF")
    ],
    targets: [
        .target(name: "ASKeys" ),
        .testTarget(name: "ASKeysTests", dependencies: ["ASKeys"]),

        .target(name: "Cache"),
        .testTarget(name: "CacheTests",
            dependencies: ["Cache"],
            resources: [.copy("cachedata.json")]),

        .target(name: "Downloader", dependencies: ["Cache"]),
        .testTarget(name: "DownloaderTests", dependencies: ["Downloader"]),

        .target(name: "Schedule",
                dependencies: [
                    "ASKeys",
                    "Cache",
                    "Downloader",
                    "UDF" ],
                resources: [
                    .copy("restaurants.json"),
                    .copy("schedule.json"),
                    .copy("trips.json") ]),
        .testTarget(name: "ScheduleTests",
                    dependencies: ["Schedule"],
                    resources: [
                        .copy("restaurants.json"),
                        .copy("schedule.json"),
                        .copy("trips.json") ])
    ]
)
