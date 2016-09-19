//
//  AlwaysReachable.swift
//  Reactor
//
//  Created by Rui Peres on 21/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import Result
import ReactiveSwift

struct AlwaysReachable: Reachable {
    
    func isConnected() -> SignalProducer<Bool, NoError> {
        return SignalProducer(value: true)
    }
}
