import PackageDescription

let package = Package(
    name: "SlackBot",
    dependencies: [
      .Package(url: "https://github.com/qutheory/vapor-tls", majorVersion: 0, minor: 4),
      .Package(url: "https://github.com/openkitten/mongokitten", majorVersion: 1, minor: 4)
    ],
    exclude: [
        "Images"
    ]
)
