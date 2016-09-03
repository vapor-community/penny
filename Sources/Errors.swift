enum BotError: Swift.Error {
    case missingConfig
    case invalidResponse
    case missingMySQLCredentials
    case missingMySQLDatabaseUrl
    case missingMySQLDatabaseName
    case unableToLoadChannels
}
