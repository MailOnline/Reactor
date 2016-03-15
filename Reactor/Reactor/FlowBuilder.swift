//
//  FlowBuilder.swift
//  Reactor
//
//  Created by Rui Peres on 15/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import Result
import ReactiveCocoa

public struct ReactorFlow<T> {
    
    typealias NetworkFlow = Resource -> SignalProducer<T, Error>
    typealias LoadFromPersistenceFlow = Void -> SignalProducer<T, Error>
    typealias SaveToPersistenceFlow = T -> SignalProducer<T, Error>
    
    public let networkFlow: Resource -> SignalProducer<T, Error>
    public let loadFromPersistenceFlow: Void -> SignalProducer<T, Error>
    public let saveToPersistenceFlow: T -> SignalProducer<T, Error>
    
   init(networkFlow: NetworkFlow, loadFromPersistenceFlow: LoadFromPersistenceFlow, saveToPersistenceFlow: SaveToPersistenceFlow) {
        
        self.networkFlow = networkFlow
        self.loadFromPersistenceFlow = loadFromPersistenceFlow
        self.saveToPersistenceFlow = saveToPersistenceFlow
    }
}

func createFlow<T where T: Mappable>(persistencePath: String, baseURL: NSURL) -> ReactorFlow<T> {
    
    let persistenceHandler = InDiskPersistenceHandler<T>(persistenceFilePath: persistencePath)
    let network = Network(baseURL: baseURL)
    let parser: NSData -> SignalProducer<T, Error> = parse
    
    let networkRequest: Resource -> SignalProducer<T, Error> = { resource in network.makeRequest(resource).map { $0.0}.flatMapLatest(parser) }
    let loadFromPersistence: Void -> SignalProducer<T, Error> = persistenceHandler.load
    let saveToPersistence: T -> SignalProducer<T, Error> = persistenceHandler.save
    
    let flow: ReactorFlow<T> = ReactorFlow(networkFlow: networkRequest, loadFromPersistenceFlow: loadFromPersistence, saveToPersistenceFlow: saveToPersistence)
    
    return flow
}

func createFlow<T where T: SequenceType, T.Generator.Element: Mappable>(persistencePath: String, baseURL: NSURL) -> ReactorFlow<T> {
    
    let persistenceHandler = InDiskPersistenceHandler<T>(persistenceFilePath: persistencePath)
    let network = Network(baseURL: baseURL)
    let parser: NSData -> SignalProducer<T, Error> = parse
    
    let networkRequest: Resource -> SignalProducer<T, Error> = { resource in network.makeRequest(resource).map { $0.0}.flatMapLatest(parser) }
    let loadFromPersistence: Void -> SignalProducer<T, Error> = persistenceHandler.load
    let saveToPersistence: T -> SignalProducer<T, Error> = persistenceHandler.save
    
    let flow: ReactorFlow<T> = ReactorFlow(networkFlow: networkRequest, loadFromPersistenceFlow: loadFromPersistence, saveToPersistenceFlow: saveToPersistence)
    
    return flow
}
