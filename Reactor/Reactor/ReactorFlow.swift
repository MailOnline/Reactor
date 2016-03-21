//
//  ReactorFlow.swift
//  Reactor
//
//  Created by Rui Peres on 15/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import Result
import ReactiveCocoa

/// Used to represent the ReactorFlow. A typical flow consists of loading from persistence, 
/// making a network request and finally saving it to persistence. All three flows are
/// public on purpose so they can be manually replaced or extended.
///
/// At very least a `NetworkFlow` must be provided, at initialization.
public struct ReactorFlow<T> {
    
    typealias NetworkFlow = Resource -> SignalProducer<T, Error>
    typealias LoadFromPersistenceFlow = Void -> SignalProducer<T, Error>
    typealias SaveToPersistenceFlow = T -> SignalProducer<T, Error>
    
    public var networkFlow: Resource -> SignalProducer<T, Error>
    public var loadFromPersistenceFlow: Void -> SignalProducer<T, Error>
    public var saveToPersistenceFlow: T -> SignalProducer<T, Error>
    
    /// If `loadFromPersistenceFlow` is not passed, the `Reactor` will bailout and hit the network
    /// If `saveToPersistenceFlow` is not passed, the `Reactor` will persist anything
    init(networkFlow: NetworkFlow, loadFromPersistenceFlow: LoadFromPersistenceFlow = {SignalProducer(error: .Persistence("Persistence bailout"))}, saveToPersistenceFlow: SaveToPersistenceFlow = SignalProducer.identity) {
        
        self.networkFlow = networkFlow
        self.loadFromPersistenceFlow = loadFromPersistenceFlow
        self.saveToPersistenceFlow = saveToPersistenceFlow
    }
}

/// Used as a factory to create a `ReactorFlow` around a single `T` that is `Mappable`
public func createFlow<T where T: Mappable>(persistencePath: String = "", baseURL: NSURL, configuration: ReactorConfiguration) -> ReactorFlow<T> {
    
    let network: Network
    if configuration.shouldCheckReachability {
        network = Network(baseURL: baseURL)
    }
    else {
        network = Network(baseURL: baseURL, reachability: AlwaysReachable())
    }
    
    let parser: NSData -> SignalProducer<T, Error> = parse
    let networkFlow: Resource -> SignalProducer<T, Error> = { resource in network.makeRequest(resource).map { $0.0}.flatMapLatest(parser) }

    if configuration.usingPersistence {
        
        let persistenceHandler = InDiskPersistenceHandler<T>(persistenceFilePath: persistencePath)
        let loadFromPersistence = persistenceHandler.load
        let saveToPersistence =  persistenceHandler.save
        
        return ReactorFlow(networkFlow: networkFlow, loadFromPersistenceFlow: loadFromPersistence, saveToPersistenceFlow: saveToPersistence)
    }
    else {
        return ReactorFlow(networkFlow: networkFlow)
    }
}

/// Used as a factory to create a `ReactorFlow` around a Sequence of `T` that are `Mappable`
public func createFlow<T where T: SequenceType, T.Generator.Element: Mappable>(persistencePath: String = "", baseURL: NSURL, configuration: ReactorConfiguration) -> ReactorFlow<T> {
    
    let network: Network
    if configuration.shouldCheckReachability {
        network = Network(baseURL: baseURL)
    }
    else {
        network = Network(baseURL: baseURL, reachability: AlwaysReachable())
    }
    
    let parser: NSData -> SignalProducer<T, Error> = parse
    let networkFlow: Resource -> SignalProducer<T, Error> = { resource in network.makeRequest(resource).map { $0.0}.flatMapLatest(parser) }
    
    if configuration.usingPersistence {
        
        let persistenceHandler = InDiskPersistenceHandler<T>(persistenceFilePath: persistencePath)
        let loadFromPersistence = persistenceHandler.load
        let saveToPersistence =  persistenceHandler.save
        
        return ReactorFlow(networkFlow: networkFlow, loadFromPersistenceFlow: loadFromPersistence, saveToPersistenceFlow: saveToPersistence)
    }
    else {
        return ReactorFlow(networkFlow: networkFlow)
    }
}
