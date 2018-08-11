import ReactiveSwift

public typealias Response = SignalProducer<(Data, URLResponse), ReactorError>

/// Represents an entity that makes requests via a NSURLSession.
/// It also makes use of a Reachable entity to check for internet connection before a request is made
/// Finally, the baseURL for the endpoint, needs to be provided before making the request. 
/// The request expects a Resource object, that has the remaining information (path, query, headers, body)
public protocol Connection {
    
    /// Used to check the connectivity, before making the request
    var reachability: Reachable { get }
    /// The session used to start the request
    var session: URLSession { get }
    /// The request base url
    var baseURL: URL { get }
    
    /// The method used to start the request. By default: `rac_dataWithRequest`
    func makeRequest(_ resource: Resource) -> Response
    
    /// Used to cancel all requests. By default: NSURLSession's `invalidateAndCancel()`
    func cancelAllConnections()
}

extension Connection {
    
    var session: URLSession { return URLSession(configuration: URLSessionConfiguration.default) }
    var baseURL: URL { return URL(string: "")! }
    
    /// The method used to start the request. By default: `rac_dataWithRequest`.
    /// It also checks the connectivity before making the request
    public func makeRequest(_ resource: Resource) -> Response {
        
        let request = resource.toRequest(self.baseURL)
        
        let networkRequest = self.session
            .reactive.data(with: request)
            .mapError { error in ReactorError.server(error.localizedDescription) }
        
        let isReachable: (Bool) -> Response = { isReachable in
            guard isReachable else { return SignalProducer(error: .noConnectivity) }
            return networkRequest
        }
        
        return reachability.isConnected()
            .mapError { _ in ReactorError.noConnectivity }
            .flatMapLatest(isReachable)
    }
    
    /// Used to cancel all requests. By default: NSURLSession's `invalidateAndCancel()`
    public func cancelAllConnections() {
        
        self.session.invalidateAndCancel()
    }
}
