import PackageDescription

let package = Package(
    name: "SlackBot",
    dependencies: [
      .Package(url: "https://github.com/vapor/vapor", majorVersion: 1),
      .Package(url: "https://github.com/vapor/mysql", majorVersion: 1)
    ],
    exclude: [
        "Images"
    ]
)
