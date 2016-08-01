import MongoKitten

final class CoinCountCollection {
    private let backing: MongoKitten.Collection

    init(_ db: Database) {
        self.backing = db["coin-count"]
    }
}

extension CoinCountCollection {
    func addCoin(to user: String) throws -> Int {
        if let existing = try find(user: user) {
            let count = existing["coins"].int + 1

            var mutable = existing
            mutable["coins"] = .int64(Int64(count))
            try backing.update(matching: existing, to: mutable)

            return count
        } else {
            try backing.insert(["user-id": .string(user), "coins": .int64(Int64(1))])
            return 1
        }
    }

    func find(user: String) throws -> Document? {
        return try backing.findOne(matching: "user-id" == user)
    }
}
