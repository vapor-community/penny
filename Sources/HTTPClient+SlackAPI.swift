import Vapor
import HTTP
import TLS
import Transport

func loadRealtimeApi(token: String, simpleLatest: Bool = true, noUnreads: Bool = true) throws -> HTTP.Response {
    let headers: [HeaderKey: String] = ["Accept": "application/json; charset=utf-8"]
    let query: [String: NodeRepresentable] = [
        "token": token,
        "simple_latest": simpleLatest.queryInt,
        "no_unreads": noUnreads.queryInt
    ]
    
    return try EngineClient.factory.get(
        "https://slack.com/api/rtm.start",
        query: query,
        headers
    )
}

extension Bool {
    fileprivate var queryInt: Int {
        // slack uses 1 / 0 in their demo
        return self ? 1 : 0
    }
}
