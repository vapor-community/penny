import HTTP
import Vapor
import Foundation
import MySQL
import TLS

setupClient()

let VERSION = "0.2.0"
let PENNY = "U1PF52H9C"
let GENERAL = "C0N67MJ83"

let configDirectory = workingDirectory + "Config/"
let config = try Settings.Config(
    prioritized: [
        .commandLine,
        .directory(root: configDirectory + "secrets"),
        .directory(root: configDirectory + "production")
    ]
)

// Config variables
guard let token = config["bot-config", "token"]?.string else { throw BotError.missingConfig }

guard let user = config["mysql", "user"]?.string, let pass = config["mysql", "pass"]?.string else { throw BotError.missingMySQLCredentials }

guard
    let host = config["mysql", "host"]?.string,
    let port = config["mysql", "port"]?.string
    else { throw BotError.missingMySQLDatabaseUrl }

guard let databaseName = config["mysql", "database"]?.string else { throw BotError.missingMySQLDatabaseName }

let mysql = try MySQL.Database(
    host: host,
    user: user,
    password: pass,
    database: databaseName
)

// WebSocket Init
let rtmResponse = try BasicClient.loadRealtimeApi(token: token)

guard let validChannels = rtmResponse.data["channels", "id"]?.array?.compactMap({ $0.string }) else { throw BotError.unableToLoadChannels }

guard let webSocketURL = rtmResponse.data["url"]?.string else { throw BotError.invalidResponse }

try WebSocket.connect(to: webSocketURL) { ws in
    print("Connected ...")

    ws.onText = { ws, text in
        let event = try JSON(bytes: text.utf8.array)
        let last3Seconds = NSDate().timeIntervalSince1970 - 3
        guard
            let channel = event["channel"]?.string,
            let message = event["text"]?.string,
            let fromId = event["user"]?.string,
            let ts = event["ts"].flatMap({ $0.string.flatMap { Double($0) } }),
            ts >= last3Seconds
            else { return }

        let threadTs = event["thread_ts"]?.string
        let trimmed = message.trimmedWhitespace()
        if trimmed.hasPrefix("<@") && trimmed.hasCoinSuffix { // leads w/ user
            guard
                let toId = trimmed.components(separatedBy: "<@").last?.components(separatedBy: ">").first,
                toId != fromId,
                fromId != PENNY
                else { return }

            if validChannels.contains(channel) {
                let total = try mysql.addCoins(for: toId)
                let response = SlackMessage(to: channel,
                                            text: "<@\(toId)> has \(total) :coin:",
                                            threadTs: threadTs)
                try ws.send(response)
            } else {
                let response = SlackMessage(to: channel,
                                            text: "Sorry, I only work in public channels. Try thanking <@\(toId)> in <#\(GENERAL)>",
                                            threadTs: threadTs)
                try ws.send(response)
            }
        } else if trimmed.hasPrefix("<@U1PF52H9C>") || trimmed.hasSuffix("<@U1PF52H9C>") {
            if trimmed.lowercased().contains(any: "hello", "hey", "hiya", "hi", "aloha", "sup") {
                let response = SlackMessage(to: channel,
                                            text: "Hey <@\(fromId)> 👋",
                                            threadTs: threadTs)
                try ws.send(response)
            } else if trimmed.lowercased().contains("version") {
                let response = SlackMessage(to: channel,
                                            text: "Current version is \(VERSION)",
                                            threadTs: threadTs)
                try ws.send(response)
            } else if trimmed.lowercased().contains("environment") {
                let env = config["app", "env"]?.string ?? "debug"
                let response = SlackMessage(to: channel,
                                            text: "Current environment is \(env)",
                                            threadTs: threadTs)
                try ws.send(response)
            } else if trimmed.lowercased().contains("top") {
                let limit = trimmed.components(separatedBy: " ")
                    .last
                    .flatMap { Int($0) }
                    ?? 10
                let top = try mysql.top(limit: limit).map { "- <@\($0["user"]?.string ?? "?")>: \($0["coins"]?.int ?? 0)" } .joined(separator: "\n")
                let response = SlackMessage(to: channel,
                                            text: "Top \(limit): \n\(top)",
                                            threadTs: threadTs)
                try ws.send(response)
            } else if trimmed.lowercased().contains("how many coins") {
                let user = trimmed.components(separatedBy: " ")
                    .lazy
                    .filter {
                        $0.hasPrefix("<@")
                        && $0.hasSuffix(">")
                        && $0 != "<@U1PF52H9C>"
                    }
                    .map { $0.dropFirst(2).dropLast() }
                    .first
                    .flatMap { String($0) }
                    ?? fromId

                let count = try mysql.coinsCount(for: user)
                let response = SlackMessage(to: channel,
                                            text: "<@\(user)> has \(count) :coin:",
                                            threadTs: threadTs)
                try ws.send(response)
            }
        }
    }

    ws.onClose = { ws, _, _, _ in
        print("\n[CLOSED]\n")
    }
}
