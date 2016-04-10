//
//  Connection.swift
//  Reactor
//
//  Created by Rui Peres on 12/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import ReactiveCocoa

public typealias Response = SignalProducer<(NSData, NSURLResponse), Error>

/// Represents an entity that makes requests via a NSURLSession.
/// It also makes use of a Reachable entity to check for internet connection before a request is made
/// Finally, the baseURL for the endpoint, needs to be provided before making the request. 
/// The request expects a Resource object, that has the remaining information (path, query, headers, body)
public protocol Connection {
    
    /// Used to check the connectivity, before making the request
    var reachability: Reachable { get }
    /// The session used to start the request
    var session: NSURLSession { get }
    /// The request base url
    var baseURL: NSURL { get }
    
    /// The method used to start the request. By default: `rac_dataWithRequest`
    func makeRequest(resource: Resource) -> Response
    
    /// Used to cancel all requests. By default: NSURLSession's `invalidateAndCancel()`
    func cancelAllConnections()
}

extension Connection {
    
    var session: NSURLSession { return NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()) }
    var baseURL: NSURL { return NSURL(string: "")! }
    
    /// The method used to start the request. By default: `rac_dataWithRequest`.
    /// It also checks the connectivity before making the request
    public func makeRequest(resource: Resource) -> Response {
        
        let request = resource.toRequest(self.baseURL)
        
        let networkRequest = self.session
            .rac_dataWithRequest(request)
            .mapError { error in Error.Server(error.localizedDescription) }
        
        let isReachable: Bool -> Response = { isReachable in
            guard isReachable else { return SignalProducer(error: .NoConnectivity) }
            return networkRequest
        }
        
        return reachability.isConnected()
            .mapError { _ in Error.NoConnectivity }
            .flatMapLatest(isReachable)
    }
    
    /// Used to cancel all requests. By default: NSURLSession's `invalidateAndCancel()`
    public func cancelAllConnections() {
        
        self.session.invalidateAndCancel()
    }
}