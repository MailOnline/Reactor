//
//  Connection.swift
//  Reactor
//
//  Created by Rui Peres on 12/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import Foundation
import ReactiveCocoa

public protocol Reachable {
    
    func isConnected() -> SignalProducer<Bool, Error>
}

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
    
    func cancelAllConnections() {
        
        self.session.invalidateAndCancel()
    }
    
    func makeConnection(resource: Resource) -> SignalProducer<(NSData, NSURLResponse), Error> {
        
        let request = resource.toRequest(self.baseURL)
        return self.session.rac_dataWithRequest(request).mapError { .Server($0.localizedDescription) }
    }
}

protocol ComposedConnection: Connection {
    
    var connection: Connection { get }
    init(connection: Connection)
}

extension ComposedConnection {
    
    var reachability: Reachable { return connection.reachability }
}
