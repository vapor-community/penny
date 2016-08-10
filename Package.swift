import PackageDescription

let package = Package(
    name: "SlackBot",
    dependencies: [
      .Package(url: "https://github.com/vapor/tls-provider", majorVersion: 0, minor: 5),
      .Package(url: "https://github.com/vapor/mysql", majorVersion: 0, minor: 3)
    ],
    exclude: [
        "Images"
    ]
)
