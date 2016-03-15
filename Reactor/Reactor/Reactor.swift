//
//  Reactor.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import ReactiveCocoa

/// The `Reactor` is nothing more than an assembler of flows.
/// A typical iOS app will have a network call, a persistence and next time the same call is made
/// it will check the persistence first. The reacto only facilitates this process by assembling the flows
/// passed in a `ReactorFlow`
public struct Reactor<T> {
    
    private let flow: ReactorFlow<T>
    
    init(flow: ReactorFlow<T>) {
        
        self.flow = flow
    }
    
    /// It will check the persistence first, if it fails it will internally call `fetchFromNetwork`
    public func fetch(resource: Resource) -> SignalProducer<T, Error> {
        
        return flow.loadFromPersistenceFlow()
            .flatMapError { _ in self.fetchFromNetwork (resource) }
    }

    // It will fetch from the network, if successful it will persist the data.
    public func fetchFromNetwork(resource: Resource) -> SignalProducer<T, Error> {
        
        return flow.networkFlow(resource)
            .flatMapLatest(flow.saveToPersistenceFlow)
    }
}

public extension Reactor where T: Mappable {
    
    // Convinience initializer to create a flow around a single `T` that is `Mappable`
    public init (persistencePath: String, baseURL: NSURL) {
        flow = createFlow(persistencePath, baseURL: baseURL)
    }
}

public extension Reactor where T: SequenceType, T.Generator.Element: Mappable {
    
    // Convinience initializer to create a flow around a Sequence of `T` that are `Mappable`
    public init (persistencePath: String, baseURL: NSURL) {
        flow = createFlow(persistencePath, baseURL: baseURL)
    }
}
