// reset db
// try mysql.execute("delete from coins")

/*
 -----------------------------
 | user    | coins           |
 | user id | number of coins |
 -----------------------------
*/

import MySQL

extension MySQL.Database {
    func addCoins(for user: String) throws -> Int {
        let command = "INSERT INTO coins (user, coins) VALUES(?, 1) ON DUPLICATE KEY UPDATE coins = coins + 1;"
        try execute(command, [user])
        return try coinsCount(for: user)
    }

    func coinsCount(for user: String) throws -> Int {
        return try execute("SELECT coins FROM coins WHERE user = ?;", [user])
            .first?["coins"]?
            .int
            ?? 0
    }

    func top(limit: Int) throws -> [[String: Node]] {
        let limit = min(limit, 25)
        return try execute("SELECT * FROM coins ORDER BY coins DESC LIMIT ?;", [limit])
    }
}
