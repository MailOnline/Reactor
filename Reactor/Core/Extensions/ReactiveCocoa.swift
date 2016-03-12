//
//  ReactiveCocoa.swift
//  Reactor
//
//  Created by Rui Peres on 12/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import ReactiveCocoa

extension SignalType {
    
    public func ignoreNext() -> Signal<Void, Self.Error> {
        return self.map { _ in }
    }
}

extension SignalProducerType {
    
    static var identity: (Value -> SignalProducer<Value, Error>) { return { SignalProducer(value: $0) } }

    @warn_unused_result(message="Did you forget to call `start` on the producer?")
    func injectSideEffect(next: Self.Value -> ()) -> SignalProducer<Self.Value, Self.Error> {
        return self.on(next: next)
    }
    
    @warn_unused_result(message="Did you forget to call `start` on the producer?")
    func flatMapLatest<U>(transform: Self.Value -> ReactiveCocoa.SignalProducer<U, Self.Error>) -> ReactiveCocoa.SignalProducer<U, Self.Error> {
        return self.flatMap(.Latest , transform: transform)
    }
}
