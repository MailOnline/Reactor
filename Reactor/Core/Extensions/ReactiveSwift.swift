//
//  ReactiveSwift.swift
//  Reactor
//
//  Created by Rui Peres on 12/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import ReactiveSwift

extension SignalProducerProtocol {
    
    /// Used to yield the same input. This is useful in scenarios where there is a possibility of having a transformation (via a flatMap)
    /// but by default, nothing will happen. It makes it much more elegant, than checking for a nil transformation and apply it conditionally
    public static var identity: ((Self.Value) -> SignalProducer<Self.Value, Self.Error>) { return { SignalProducer(value: $0) } }

    /// More explicit call to `on(next: next)`.
    public func injectSideEffect(_ next: @escaping (Self.Value) -> ()) -> SignalProducer<Self.Value, Self.Error> {
        return self.on(value: next)
    }
    
    /// Convenience method to `flatMap(.latest , transform: transform)`
    public func flatMapLatest<U>(_ transform: @escaping (Self.Value) -> SignalProducer<U, Self.Error>) -> SignalProducer<U, Self.Error> {
        return self.flatMap(.latest, transform: transform)
    }
}
