import PackageDescription

let package = Package(
    name: "SwiftFuture",
    dependencies: [
        .Package(url: "https://github.com/antitypical/Result.git", majorVersion: 3)
    ]
)
