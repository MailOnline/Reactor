public enum ReactorError: Error, Equatable {
    case server(String)
    case noConnectivity
    case persistence(String)
    case parser(String)
}
