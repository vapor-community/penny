import Node
import Vapor

struct SlackMessage {
    let id: UInt32
    let channel: String
    let text: String
    let threadTs: String?

    init(to channel: String, text: String, threadTs: String?) {
        self.id = UInt32.random()
        self.channel = channel
        self.text = text
        self.threadTs = threadTs
    }
}

extension SlackMessage: NodeRepresentable {
    func makeNode(in context: Context? = nil) throws -> Node {
        var node: [String: NodeConvertible] = [
            "id": id,
            "channel": channel,
            "type": "message",
            "text": text
        ]
        
        if let threadTs = threadTs {
            node["thread_ts"] = threadTs
        }
        
        return try Node(node: node)
    }
}
