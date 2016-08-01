enum BotError: Swift.Error {
    case missingConfig
    case invalidResponse
    case missingMlabCredentials
    case missingMlabDatabaseUrl
    case missingMlabDatabaseName
}
