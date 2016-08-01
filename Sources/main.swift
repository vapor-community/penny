import HTTP
import Vapor
import VaporTLS
import MongoKitten
import Foundation

let VERSION = "0.1.0"

let config = try Config(workingDirectory: workingDirectory)

// Config variables
guard let token = config["bot-config", "token"].string else { throw BotError.missingConfig }
guard let user = config["mlab", "user"].string, let pass = config["mlab", "pass"].string else { throw BotError.missingMlabCredentials }
guard let uri = config["mlab", "uri"].string else { throw BotError.missingMlabDatabaseUrl }
guard let databaseName = config["mlab", "database"].string else { throw BotError.missingMlabDatabaseName }

// Database Init
let server = try Server("mongodb://\(user):\(pass)@\(uri)", automatically: true)
let database = server[databaseName]
let coinCountCollection = CoinCountCollection(database)

// WebSocket Init
let rtmResponse = try Client.loadRealtimeApi(token: token)
guard let webSocketURL = rtmResponse.data["url"].string else { throw BotError.invalidResponse }

try WebSocket.connect(to: webSocketURL, using: Client<TLSClientStream>.self) { ws in
    print("Connected to \(webSocketURL)")

    ws.onText = { ws, text in
        let event = try JSON(bytes: text.utf8.array)
        print("Event: \(event)")

        guard
            let channel = event["channel"]?.string,
            let message = event["text"]?.string,
            let fromId = event["user"]?.string
            else { return }

        let trimmed = message.trimmedWhitespace()
        if trimmed.hasPrefix("<@") && trimmed.hasCoinSuffix { // leads w/ user
            guard let toId = trimmed.components(separatedBy: "<@").last?.components(separatedBy: ">").first, toId != fromId else { return }
            let total = try coinCountCollection.addCoin(to: toId)
            let response = SlackMessage(to: channel, text: "<@\(toId)> has \(total) :coin:")
            try ws.send(response)
        } else if trimmed.hasPrefix("<@U1PF52H9C>") || trimmed.hasSuffix("<@U1PF52H9C>") {
            if trimmed.lowercased().contains(any: "hello", "hey", "hiya", "hi", "aloha", "sup") {
                let response = SlackMessage(to: channel, text: "Hey <@\(fromId)> 👋")
                try ws.send(response)
            } else if trimmed.lowercased().contains("version") {
                let response = SlackMessage(to: channel, text: "Current version is \(VERSION)")
                try ws.send(response)
            } else if trimmed.lowercased().contains("environment") {
                let response = SlackMessage(to: channel, text: "Current environment is \(config.environment)")
                try ws.send(response)
            }
        }
    }

    ws.onClose = { ws, _, _, _ in
        print("\n[CLOSED]\n")
    }
}
