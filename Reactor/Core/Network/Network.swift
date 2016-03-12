//
//  Network.swift
//  Reactor
//
//  Created by Rui Peres on 12/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import Foundation

final class Network: Connection {
    
    let session: NSURLSession
    let baseURL: NSURL
    let reachability: Reachable
    
    init(session: NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()), baseURL: NSURL, reachability: Reachable ) {
        
        self.session = session
        self.baseURL = baseURL
        self.reachability = reachability
    }
    
    deinit {
        self.cancelAllConnections()
    }
}
