//
//  Network.swift
//  Reactor
//
//  Created by Rui Peres on 12/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import ReactiveCocoa

public typealias ResponseModifier = (NSData, NSURLResponse) -> Response

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
    }
    
    deinit {
        self.cancelAllConnections()
    }
}
