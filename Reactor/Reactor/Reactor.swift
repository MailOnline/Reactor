//
//  Reactor.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import ReactiveCocoa

struct ReactorFlow<T> {
    
    let networkRequest: Resource -> SignalProducer<T, Error>
    let loadFromPersistence: Void -> SignalProducer<T, Error>
    let saveToPersistence: T -> SignalProducer<T, Error>
}

struct Reactor<T> {
    
    private let flow: ReactorFlow<T>
    
    init(flow: ReactorFlow<T>) {
        
        self.flow = flow
    }
    
    func fetch(resource: Resource) -> SignalProducer<T, Error> {
        
        let loadFromPersistence = flow.loadFromPersistence()
        
        return loadFromPersistence.flatMapError { _ in self.fetchFromNetwork (resource) }
    }
    
    func fetchFromNetwork(resource: Resource) -> SignalProducer<T, Error> {
        
        let saveToPersistence = flow.saveToPersistence
        let networkRequest = flow.networkRequest
        
        return networkRequest(resource)
            .flatMapLatest(saveToPersistence)
    }
}

extension Reactor where T: Mappable {
    
    init (persistencePath: String, baseURL: NSURL) {
        self.flow = createFlow(persistencePath, baseURL: baseURL)
    }
}

extension Reactor where T: SequenceType, T.Generator.Element: Mappable {
    
    init (persistencePath: String, baseURL: NSURL) {
        self.flow = createFlow(persistencePath, baseURL: baseURL)
    }
}
