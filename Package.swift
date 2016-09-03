import PackageDescription

let package = Package(
    name: "SlackBot",
    dependencies: [
      .Package(url: "https://github.com/vapor/vapor", majorVersion: 0, minor: 17),
      .Package(url: "https://github.com/vapor/mysql", majorVersion: 0, minor: 5)
    ],
    exclude: [
        "Images"
    ]
)
