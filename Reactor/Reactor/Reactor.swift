//
//  Reactor.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import ReactiveCocoa

public struct Reactor<T> {
    
    private let flow: ReactorFlow<T>
    
    init(flow: ReactorFlow<T>) {
        
        self.flow = flow
    }
    
    public func fetch(resource: Resource) -> SignalProducer<T, Error> {
        
        return flow.loadFromPersistenceFlow()
            .flatMapError { _ in self.fetchFromNetwork (resource) }
    }
    
    public func fetchFromNetwork(resource: Resource) -> SignalProducer<T, Error> {
        
        return flow.networkFlow(resource)
            .flatMapLatest(flow.saveToPersistenceFlow)
    }
}

public extension Reactor where T: Mappable {
    
    public init (persistencePath: String, baseURL: NSURL) {
        flow = createFlow(persistencePath, baseURL: baseURL)
    }
}

public extension Reactor where T: SequenceType, T.Generator.Element: Mappable {
    
    public init (persistencePath: String, baseURL: NSURL) {
        flow = createFlow(persistencePath, baseURL: baseURL)
    }
}
