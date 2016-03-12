//
//  Connection.swift
//  Reactor
//
//  Created by Rui Peres on 12/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import ReactiveCocoa

public protocol Connection {
    
    var reachability: Reachable { get }
    var session: NSURLSession { get }
    var baseURL: NSURL { get }
    
    func makeConnection(resource: Resource) -> SignalProducer<(NSData, NSURLResponse), Error>
    func cancelAllConnections()
}

extension Connection {
    
    var session: NSURLSession { return NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()) }
    var baseURL: NSURL { return NSURL(string: "")! }
    
    public func cancelAllConnections() {
        
        self.session.invalidateAndCancel()
    }
}

protocol ComposedConnection: Connection {
    
    var connection: Connection { get }
    init(connection: Connection)
}

extension ComposedConnection {
    
    var reachability: Reachable { return connection.reachability }
}
