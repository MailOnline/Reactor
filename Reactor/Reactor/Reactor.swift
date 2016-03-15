//
//  Reactor.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import ReactiveCocoa

struct ReactorFlow<T> {
    
    let networkFlow: Resource -> SignalProducer<T, Error>
    let loadFromPersistenceFlow: Void -> SignalProducer<T, Error>
    let saveToPersistenceFlow: T -> SignalProducer<T, Error>
}

struct Reactor<T> {
    
    private let flow: ReactorFlow<T>
    
    init(flow: ReactorFlow<T>) {
        
        self.flow = flow
    }
    
    func fetch(resource: Resource) -> SignalProducer<T, Error> {
        
        return flow.loadFromPersistenceFlow()
            .flatMapError { _ in self.fetchFromNetwork (resource) }
    }
    
    func fetchFromNetwork(resource: Resource) -> SignalProducer<T, Error> {
        
        return flow.networkFlow(resource)
            .flatMapLatest(flow.saveToPersistenceFlow)
    }
}

extension Reactor where T: Mappable {
    
    init (persistencePath: String, baseURL: NSURL) {
        flow = createFlow(persistencePath, baseURL: baseURL)
    }
}

extension Reactor where T: SequenceType, T.Generator.Element: Mappable {
    
    init (persistencePath: String, baseURL: NSURL) {
        flow = createFlow(persistencePath, baseURL: baseURL)
    }
}
