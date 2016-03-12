//
//  ReactiveCocoa.swift
//  Reactor
//
//  Created by Rui Peres on 12/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import ReactiveCocoa

extension SignalProducerType {
    
   static var identity: (Value -> SignalProducer<Value, Error>) { return { SignalProducer(value: $0) } }
}