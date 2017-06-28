// reset db
// try mysql.execute("delete from coins")

/*
 -----------------------------
 | user    | coins           |
 | user id | number of coins |
 -----------------------------
*/

import MySQL

extension MySQL.Connection {
    func addCoins(for user: String) throws -> Int {
        let command = "INSERT INTO coins (user, coins) VALUES(?, 1) ON DUPLICATE KEY UPDATE coins = coins + 1;"
        try execute(command, [user])
        return try coinsCount(for: user)
    }

    func coinsCount(for user: String) throws -> Int {
        return try execute("SELECT coins FROM coins WHERE user = ?;", [user])
            .array?
            .first?["coins"]?
            .int
            ?? 0
    }

    func top(limit: Int) throws -> [Node] {
        let limit = min(limit, 25)
        return try execute("SELECT * FROM coins ORDER BY coins DESC LIMIT ?;", [limit]).array ?? []
    }

    func set(coins: Int, for user: String) throws {
        let command = "INSERT INTO coins (user, coins) VALUES(?, ?) ON DUPLICATE KEY UPDATE coins = ?;"
        try execute(command, [user, coins, coins])
    }
}
