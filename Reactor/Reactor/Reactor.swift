//
//  Reactor.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import ReactiveCocoa

public enum Configuration<ConfigurationInput> {
    case Enabled(ConfigurationInput)
    case Disabled
}

public enum PersistenceConfiguration<LoadInput, SaveInput> {
    case Enabled(LoadInput, SaveInput)
    case Disabled
}

public protocol ReactorType {
    associatedtype Model
    associatedtype LoadInput
    associatedtype SaveInput
    
    var flow: ReactorFlow<Model, LoadInput, SaveInput> { get }
    var configuration: CoreConfigurable { get }
}

extension Reactor: ReactorType {
    
    public func fetch(resource: Resource, persistenceConfiguration: PersistenceConfiguration<LoadInput, SaveInput> = .Disabled) -> SignalProducer<Model, Error> {
        
        switch persistenceConfiguration {
        case .Enabled(let loadInput, let saveConfiguration):
            return flow.loadFromPersistenceFlow(loadInput)
                .startOn(QueueScheduler(name: "queue.reactor"))
                .flatMapError { _ in self.fetchFromNetwork (resource, saveConfiguration: .Enabled(saveConfiguration)) }
        case .Disabled:
            return self.fetchFromNetwork(resource)
        }
    }
    
    /// It will fetch from the network, skipping the persistence
    public func fetchFromNetwork(resource: Resource, saveConfiguration: Configuration<SaveInput> = .Disabled) -> SignalProducer<Model, Error> {
        
        let networkFlow = flow.networkFlow(resource)
            .startOn(QueueScheduler(name: "queue.reactor"))
        
        switch saveConfiguration {
        case .Enabled(let saveInput):
            let saveFlow = curry(flow.saveToPersistenceFlow)(saveInput)
            let saveToPersistence = flip(curry(shouldFailSaveToPersistenceModifier))(saveFlow)
            return shouldWaitForSaveToPersistence(networkFlow, saveToPersistenceFlow: saveToPersistence)
        case .Disabled:
            return shouldWaitForSaveToPersistence(networkFlow, saveToPersistenceFlow: { _ in SignalProducer.empty })
        }
    }
    
    private func shouldFailSaveToPersistenceModifier(result: Model, saveToPersistenceFlow: Model -> SignalProducer<Model, Error>) -> SignalProducer<Model, Error> {
        
        guard configuration.shouldFailWhenSaveToPersistenceFails == false else { return saveToPersistenceFlow(result) }
        
        return saveToPersistenceFlow(result).flatMapError { _ in SignalProducer(value: result) }
    }
    
    private func shouldWaitForSaveToPersistence(flow: SignalProducer<Model, Error>, saveToPersistenceFlow: Model -> SignalProducer<Model, Error>) -> SignalProducer<Model, Error> {
        
        guard configuration.shouldWaitForSaveToPersistence == false else { return flow.flatMapLatest(saveToPersistenceFlow) }
        
        return flow.injectSideEffect { saveToPersistenceFlow($0).start() }
    }
}

/// The `Reactor` is nothing more than an assembler of flows.
/// A typical iOS app will have a network call, a persistence and next time the same call is made
/// it will check the persistence first. The Reactor's job is to facilitate this process by assembling the flows
/// passed in a `ReactorFlow`
public struct Reactor<Model, LoadInput, SaveInput> {
    
    public let flow: ReactorFlow<Model, LoadInput, SaveInput>
    public let configuration: CoreConfigurable
    
    init(flow: ReactorFlow<Model, LoadInput, SaveInput>, configuration: CoreConfigurable = CoreConfiguration()) {
        self.flow = flow
        self.configuration = configuration
    }
}
