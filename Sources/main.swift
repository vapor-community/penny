import HTTP
import Vapor
import VaporTLS
import Foundation

import MySQL

let VERSION = "0.1.0"

let config = try Config(workingDirectory: workingDirectory)

// Config variables
guard let token = config["bot-config", "token"].string else { throw BotError.missingConfig }
guard let user = config["mysql", "user"].string, let pass = config["mysql", "pass"].string else { throw BotError.missingMlabCredentials }

guard
    let host = config["mysql", "host"].string,
    let port = config["mysql", "port"].string
    else { throw BotError.missingMlabDatabaseUrl }
guard let databaseName = config["mysql", "database"].string else { throw BotError.missingMlabDatabaseName }

let mysql = try MySQL.Database(
    host: host,
    user: user,
    password: pass,
    database: databaseName
)

// WebSocket Init
let rtmResponse = try Client.loadRealtimeApi(token: token)
guard let webSocketURL = rtmResponse.data["url"].string else { throw BotError.invalidResponse }

try WebSocket.connect(to: webSocketURL, using: Client<TLSClientStream>.self) { ws in
    print("Connected to \(webSocketURL)")

    ws.onText = { ws, text in
        let event = try JSON(bytes: text.utf8.array)

        guard
            let channel = event["channel"]?.string,
            let message = event["text"]?.string,
            let fromId = event["user"]?.string
            else { return }

        let trimmed = message.trimmedWhitespace()
        if trimmed.hasPrefix("<@") && trimmed.hasCoinSuffix { // leads w/ user
            guard let toId = trimmed.components(separatedBy: "<@").last?.components(separatedBy: ">").first, toId != fromId else { return }
            let total = try mysql.addCoins(for: toId)
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
            } else if trimmed.lowercased().contains("top") {
                guard let limit = trimmed.components(separatedBy: " ").last.flatMap({ Int($0) }) else { return }
                let top = try mysql.top(limit: limit).map { "- <@\($0["user"]?.string ?? "?")>: \($0["coins"]?.int ?? 0)" } .joined(separator: "\n")
                let response = SlackMessage(to: channel, text: "Top \(limit): \n\(top)")
                try ws.send(response)
            } else if trimmed.lowercased().contains("how many coins") {
                let user = trimmed.components(separatedBy: " ")
                    .lazy
                    .filter({
                        $0.hasPrefix("<@")
                        && $0.hasSuffix(">")
                        && $0 != "<@U1PF52H9C>"
                    })
                    .map({ $0.characters.dropFirst(2).dropLast() })
                    .first
                    .flatMap({ String($0) })
                    ?? fromId

                let count = try mysql.coinsCount(for: user)
                let response = SlackMessage(to: channel, text: "<@\(user)> has \(count) :coin:")
                try ws.send(response)
            }
        }
    }

    ws.onClose = { ws, _, _, _ in
        print("\n[CLOSED]\n")
    }
}
