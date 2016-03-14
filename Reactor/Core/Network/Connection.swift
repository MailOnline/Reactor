//
//  Connection.swift
//  Reactor
//
//  Created by Rui Peres on 12/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import ReactiveCocoa

public typealias Response = SignalProducer<(NSData, NSURLResponse), Error>

public protocol Connection {
    
    var reachability: Reachable { get }
    var session: NSURLSession { get }
    var baseURL: NSURL { get }
    
    func makeRequest(resource: Resource) -> Response
    func cancelAllConnections()
}

extension Connection {
    
    var session: NSURLSession { return NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()) }
    var baseURL: NSURL { return NSURL(string: "")! }
    
    public func cancelAllConnections() {
        
        self.session.invalidateAndCancel()
    }
    
    func makeRequest(resource: Resource) -> Response {
        
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
}

protocol ComposedConnection: Connection {
    
    var connection: Connection { get }
    init(connection: Connection)
}

extension ComposedConnection {
    
    var reachability: Reachable { return connection.reachability }
}
