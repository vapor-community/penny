import MySQL

final class CoinCountCollection {
//    private let backing: MongoKitten.Collection

    init(_ db: Any) {
        fatalError()
//        self.backing = db["coin-count"]
    }
}

extension CoinCountCollection {
    func addCoin(to user: String) throws -> Int {
        fatalError()
//        if let existing = try find(user: user) {
//            let count = existing["coins"].int + 1
//
//            var mutable = existing
//            mutable["coins"] = .int64(Int64(count))
//            try backing.update(matching: existing, to: mutable)
//
//            return count
//        } else {
//            try backing.insert(["user-id": .string(user), "coins": .int64(Int64(1))])
//            return 1
//        }
    }

    func find(user: String) throws -> Any? {
        fatalError()
//        return try backing.findOne(matching: "user-id" == user)
    }
}
