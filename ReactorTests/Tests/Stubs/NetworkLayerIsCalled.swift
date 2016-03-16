//
//  NetworkLayerIsCalled.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import ReactiveCocoa
@testable import Reactor

class NetworkLayerIsCalled : Connection  {
    
    var reachability: Reachable = MutableReachability()
    
    private let connectionCalled: Void -> Void
    
    init(connectionCalled: Void -> Void) {
        
        self.connectionCalled = connectionCalled
    }
    
    func makeRequest(resource: Resource) -> Response {
        connectionCalled()
        return SignalProducer.empty
    }
}
