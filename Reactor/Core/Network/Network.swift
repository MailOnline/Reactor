//
//  Network.swift
//  Reactor
//
//  Created by Rui Peres on 12/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import ReactiveCocoa

typealias ResponseModifier = (NSData, NSURLResponse) -> SignalProducer<(NSData, NSURLResponse), Error>

final class Network: Connection {
    
    let session: NSURLSession
    let baseURL: NSURL
    let reachability: Reachable
    let responseModifier: ResponseModifier
    
    init(session: NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()), baseURL: NSURL, reachability: Reachable = Reachability(), responseModifier: ResponseModifier = SignalProducer.identity) {
        
        self.session = session
        self.baseURL = baseURL
        self.reachability = reachability
        self.responseModifier = responseModifier
    }
    
    func makeRequest(resource: Resource) -> SignalProducer<(NSData, NSURLResponse), Error> {
        
        let request = resource.toRequest(self.baseURL)
        
        return session.rac_dataWithRequest(request)
            .mapError { .Server($0.localizedDescription) }
            .flatMap(.Latest, transform: responseModifier)
    }
    
    deinit {
        self.cancelAllConnections()
    }
}
