import ReactiveSwift

public protocol Connectable {
    /// The method used to start the request. By default: `rac_dataWithRequest`
    func data(_ request: URLRequest) -> SignalProducer<(Data, URLResponse), ReactorError>
}

extension URLSession: Connectable {
    public func data(_ request: URLRequest) -> SignalProducer<(Data, URLResponse), ReactorError> {
        return self.reactive
            .data(with: request)
            .mapError(ReactorError.server)
    }
}
