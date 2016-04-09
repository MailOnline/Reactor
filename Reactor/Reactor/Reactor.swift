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
/// it will check the persistence first. The Reactor's job is to facilitate this process by assembling the flows
/// passed in a `ReactorFlow`
public struct Reactor<T> {
    
    private let flow: ReactorFlow<T>
    private let configuration: ReactorConfiguration
    
    init(flow: ReactorFlow<T>, configuration: ReactorConfiguration = ReactorConfiguration()) {
        
        self.flow = flow
        self.configuration = configuration
    }
    
    /// It will check the persistence first, if it fails it will internally call `fetchFromNetwork`
    public func fetch(resource: Resource) -> SignalProducer<T, Error> {
        
        return flow.loadFromPersistenceFlow()
            .startOn(QueueScheduler(name: "Reactor"))
            .flatMapError { _ in self.fetchFromNetwork (resource) }
    }

    // It will fetch from the network, if successful it will persist the data.
    public func fetchFromNetwork(resource: Resource) -> SignalProducer<T, Error> {
        
        let saveToPersistence = flip(curry(modifySaveToPersistenceFlow))(flow.saveToPersistenceFlow)
        
        return flow.networkFlow(resource)
            .startOn(QueueScheduler(name: "Reactor"))
            .flatMapLatest(saveToPersistence)
    }
    
    private func modifySaveToPersistenceFlow(result: T, saveToPersistenceFlow: T -> SignalProducer<T, Error>) -> SignalProducer<T, Error> {
        
        guard configuration.flowShouldFailWhenSaveToPersistenceFails == false else { return saveToPersistenceFlow(result) }
        
        return saveToPersistenceFlow(result).flatMapError { _ in SignalProducer(value: result) }
    }
}

public extension Reactor where T: Mappable {
    
    // Convenience initializer to create a `ReactorFlow` for a single `T: Mappable`
    public init (persistencePath: String = "", baseURL: NSURL, configuration: ReactorConfiguration = ReactorConfiguration()) {
        flow = createFlow(persistencePath, baseURL: baseURL, configuration: configuration)
        self.configuration = configuration
    }
}

public extension Reactor where T: SequenceType, T.Generator.Element: Mappable {
    
    // Convenience initializer to create a `ReactorFlow` for a `SequenceType` of `T: Mappable`
    public init (persistencePath: String = "", baseURL: NSURL, configuration: ReactorConfiguration = ReactorConfiguration()) {
        flow = createFlow(persistencePath, baseURL: baseURL, configuration: configuration)
        self.configuration = configuration
    }
}
