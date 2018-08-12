import Result

public enum ReactorError: Error {
    case server(AnyError)
    case noConnectivity
    case persistence(String)
    case parser(String)
}
