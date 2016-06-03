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
/// public on purpose, so they can be manually replaced or extended.
///
/// At very least a `NetworkFlow` must be provided, at initialization.
public struct ReactorFlow<Model, LoadInput, SaveInput> {
    
    public typealias NetworkFlow = Resource -> SignalProducer<Model, Error>
    public typealias LoadFromPersistenceFlow = LoadInput -> SignalProducer<Model, Error>
    public typealias SaveToPersistenceFlow = (SaveInput, Model) -> SignalProducer<Model, Error>
    
    public var networkFlow: NetworkFlow
    public var loadFromPersistenceFlow: LoadFromPersistenceFlow
    public var saveToPersistenceFlow: SaveToPersistenceFlow
    
    /// If `loadFromPersistenceFlow` is not passed, the `Reactor` will bailout and hit the network
    /// If `saveToPersistenceFlow` is not passed, the `Reactor` will persist anything
    init(networkFlow: NetworkFlow, loadFromPersistenceFlow: LoadFromPersistenceFlow = {_ in SignalProducer(error: .Persistence("Persistence bailout"))}, saveToPersistenceFlow: SaveToPersistenceFlow = { (saveInput, models) in SignalProducer(value: models)}) {
        
        self.networkFlow = networkFlow
        self.loadFromPersistenceFlow = loadFromPersistenceFlow
        self.saveToPersistenceFlow = saveToPersistenceFlow
    }
}

/// Used as a factory to create a `ReactorFlow` for a single `T: Mappable`
public func createFlow<Model where Model: Mappable>(connection: Connection, configuration: FlowConfigurable = FlowConfiguration()) -> ReactorFlow<Model, String, String> {
    
    let parser: NSData -> SignalProducer<Model, Error> = parse
    let networkFlow: Resource -> SignalProducer<Model, Error> = { resource in connection.makeRequest(resource).map { $0.0}.flatMapLatest(parser) }
    
    let persistenceHandler = InDiskPersistenceHandler<Model>()
    let loadFromPersistence = persistenceHandler.load
    let saveToPersistence =  persistenceHandler.save
    
    return ReactorFlow(networkFlow: networkFlow, loadFromPersistenceFlow: loadFromPersistence, saveToPersistenceFlow: saveToPersistence)
}

/// Used as a factory to create a `ReactorFlow` for a single `T: Mappable`
public func createFlow<Model where Model: Mappable>(baseURL: NSURL, configuration: FlowConfigurable = FlowConfiguration()) -> ReactorFlow<Model, String, String> {
    
    let connection = createConnection(baseURL, shouldCheckReachability: configuration.shouldCheckReachability)
    return createFlow(connection, configuration: configuration)
}

/// Used as a factory to create a `ReactorFlow` for a `SequenceType` of `T: Mappable`
public func createFlow<Model where Model: SequenceType, Model.Generator.Element: Mappable>(connection: Connection, configuration: FlowConfigurable = FlowConfiguration()) -> ReactorFlow<Model, String, String> {
    
    let parser: NSData -> SignalProducer<Model, Error> = configuration.shouldPrune ? prunedParse : strictParse
    let networkFlow: Resource -> SignalProducer<Model, Error> = { resource in connection.makeRequest(resource).map { $0.0}.flatMapLatest(parser) }
    
    let persistenceHandler = InDiskPersistenceHandler<Model>()
    let loadFromPersistence = persistenceHandler.load
    let saveToPersistence =  persistenceHandler.save
    
    return ReactorFlow(networkFlow: networkFlow, loadFromPersistenceFlow: loadFromPersistence, saveToPersistenceFlow: saveToPersistence)
}

/// Used as a factory to create a `ReactorFlow` for a `SequenceType` of `T: Mappable`
public func createFlow<Model where Model: SequenceType, Model.Generator.Element: Mappable>(baseURL: NSURL, configuration: FlowConfigurable = FlowConfiguration()) -> ReactorFlow<Model, String, String> {
    
    let connection = createConnection(baseURL, shouldCheckReachability: configuration.shouldCheckReachability)
    return createFlow(connection, configuration: configuration)
}

private func createConnection(baseURL: NSURL, shouldCheckReachability: Bool) -> Connection {
    
    if shouldCheckReachability {
        return Network(baseURL: baseURL)
    }
    else {
        return Network(baseURL: baseURL, reachability: AlwaysReachable())
    }
}
