import PackageDescription

let package = Package(
    name: "SlackBot",
    dependencies: [
      .Package(url: "https://github.com/vapor/vapor", majorVersion: 2),
      .Package(url: "https://github.com/vapor/mysql", majorVersion: 2)
    ],
    exclude: [
        "Images"
    ]
)
