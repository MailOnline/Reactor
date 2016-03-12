//
//  Network.swift
//  Reactor
//
//  Created by Rui Peres on 12/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import ReactiveCocoa

typealias Response = SignalProducer<(NSData, NSURLResponse), Error>
typealias ResponseModifier = (NSData, NSURLResponse) -> Response

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
    
    func makeRequest(resource: Resource) -> Response {
        
        let request = resource.toRequest(self.baseURL)
        
        let networkRequest = self.session
            .rac_dataWithRequest(request)
            .mapError {
                print($0)
               return .Server($0.localizedDescription)
            }
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
