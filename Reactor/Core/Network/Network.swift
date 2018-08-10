import ReactiveSwift

public typealias ResponseModifier = (Data, URLResponse) -> Response

/// Concrete implementation of the Connection protocol.
/// Offers a `responseModifiers`, that allows the consumer to inject custom logic.
/// For example a status code 300 could be considered an error. This could be achieved by:
///
/// ```
/// responseModifier = { (data, response) in
///
///   let httpResponse = response as! NSHTTPURLResponse
///   let statusCode = httpResponse.statusCode
///
///   if statusCode == 300  {
///        return SignalProducer(error: .Server("Bad status code"))
///    }
///    else {
///       return SignalProducer(value: (data, response))
///    }
/// }
/// ```
/// By default the `responseModifier` is a `SignalProducer.identity` ( T -> SignalProducer<T, Error> )
///
/// For more information check the Connection protocol
///
public final class Network: Connection {
    
    public let session: URLSession
    public let baseURL: URL
    public let reachability: Reachable
    public let responseModifier: ResponseModifier
    
    init(session: URLSession = URLSession(configuration: URLSessionConfiguration.default), baseURL: URL, reachability: Reachable = Reachability(), responseModifier: @escaping ResponseModifier = SignalProducer.identity) {
        
        self.session = session
        self.baseURL = baseURL
        self.reachability = reachability
        self.responseModifier = responseModifier
    }
    
   public func makeRequest(_ resource: Resource) -> Response {
        
        let request = resource.toRequest(self.baseURL)
        
        let networkRequest = self.session
            .rac_data(with: request)
            .mapError { .server($0.localizedDescription) }
            .flatMapLatest(self.responseModifier)
        
        let isReachable: (Bool) -> Response = { isReachable in
            guard isReachable else { return SignalProducer(error: .noConnectivity) }
            return networkRequest
        }
        
        return reachability.isConnected()
            .mapError { _ in ReactorError.noConnectivity }
            .flatMapLatest(isReachable)
            .start(on: QueueScheduler(name: "Network"))
    }
    
    deinit {
        self.cancelAllConnections()
    }
}
