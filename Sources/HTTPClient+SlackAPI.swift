import Vapor
import VaporTLS
import HTTP

extension HTTP.Client where ClientStreamType: TLSClientStream {
    static func loadRealtimeApi(token: String, simpleLatest: Bool = true, noUnreads: Bool = true) throws -> HTTP.Response {
        let headers: [HeaderKey: String] = ["Accept": "application/json; charset=utf-8"]
        let query: [String: CustomStringConvertible] = [
            "token": token,
            "simple_latest": simpleLatest.queryInt,
            "no_unreads": noUnreads.queryInt
        ]
        return try get("https://slack.com/api/rtm.start",
                       headers: headers,
                       query: query)
    }

    static func react(to timestamp: String, in channel: String, emoji: String, token: String) throws {
        let headers: [HeaderKey: String] = ["Accept": "application/json; charset=utf-8"]
        let query: [String: CustomStringConvertible] = [
            "token": token,
            "name": emoji,
            "timestamp": timestamp,
            "channel": channel
        ]
        _ = try post("https://slack.com/api/reactions.add",
                     headers: headers,
                     query: query)
    }
}

extension Bool {
    private var queryInt: Int {
        // slack uses 1 / 0 in their demo
        return self ? 1 : 0
    }
}
