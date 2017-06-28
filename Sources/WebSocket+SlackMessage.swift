import Vapor

extension WebSocket {
    func send(_ node: NodeRepresentable) throws {
        let json = try node.converted(to: JSON.self, in: JSON.defaultContext)
        let message = try json.makeBytes()
        // json MUST send as serialized string
        try send(message.makeString())
    }
}
