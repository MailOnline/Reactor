//
//  ReactiveCocoa.swift
//  Reactor
//
//  Created by Rui Peres on 12/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import ReactiveCocoa

extension SignalProducerType {
    
    /// Used to yield the same input. This is useful in scenarios where there is a possibility of having a transformation (via a flatMap)
    /// but by default, nothing will happen. It makes it much more elegant, than checking for a nil transformation and apply it conditionally
    public static var identity: (Value -> SignalProducer<Value, Error>) { return { SignalProducer(value: $0) } }

    /// More explicit call to `on(next: next)`.
    @warn_unused_result(message="Did you forget to call `start` on the producer?")
    public func injectSideEffect(next: Self.Value -> ()) -> SignalProducer<Self.Value, Self.Error> {
        return self.on(next: next)
    }
    
    /// Convinience method to `flatMap(.Latest , transform: transform)`
    @warn_unused_result(message="Did you forget to call `start` on the producer?")
    public func flatMapLatest<U>(transform: Self.Value -> ReactiveCocoa.SignalProducer<U, Self.Error>) -> ReactiveCocoa.SignalProducer<U, Self.Error> {
        return self.flatMap(.Latest , transform: transform)
    }
}
