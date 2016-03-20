//
//  Network.swift
//  Reactor
//
//  Created by Rui Peres on 12/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import ReactiveCocoa

public typealias ResponseModifier = (NSData, NSURLResponse) -> Response

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
    
    public let session: NSURLSession
    public let baseURL: NSURL
    public let reachability: Reachable
    public let responseModifier: ResponseModifier
    
    init(session: NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()), baseURL: NSURL, reachability: Reachable = Reachability(), responseModifier: ResponseModifier = SignalProducer.identity) {
        
        self.session = session
        self.baseURL = baseURL
        self.reachability = reachability
        self.responseModifier = responseModifier
    }
    
   public func makeRequest(resource: Resource) -> Response {
        
        let request = resource.toRequest(self.baseURL)
        
        let networkRequest = self.session
            .rac_dataWithRequest(request)
            .mapError { .Server($0.localizedDescription) }
            .flatMapLatest(self.responseModifier)
        
        let isReachable: Bool -> Response = { isReachable in
            guard isReachable else { return SignalProducer(error: .NoConnectivity) }
            return networkRequest
        }
        
        return reachability.isConnected()
            .mapError { _ in Error.NoConnectivity }
            .flatMapLatest(isReachable)
            .startOn(QueueScheduler(name: "Network"))
    }
    
    deinit {
        self.cancelAllConnections()
    }
}
