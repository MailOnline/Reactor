//
//  MutableReachability.swift
//  Reactor
//
//  Created by Rui Peres on 12/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import Result
import ReactiveCocoa
@testable import Reactor

struct MutableReachability: Reachable {
    
    private let isReachable: Bool
    
    init(isReachable: Bool = true) {
        self.isReachable = isReachable
    }
    
    func isConnected() -> SignalProducer<Bool, NoError> {
        return SignalProducer(value: self.isReachable)
    }
}