//
//  InDiskPersistence.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import Result
import ReactiveCocoa

public protocol InDiskElementsPersistence {
    typealias Model: Mappable
    
    func load() -> SignalProducer<[Model], Error>
    func save(model: [Model]) ->  SignalProducer<[Model], Error>
    
    func hasPersistenceExpired() -> SignalProducer<Bool, NoError>
}

public protocol InDiskElementPersistence {
    typealias Model: Mappable
    
    func load() -> SignalProducer<Model, Error>
    func save(model: Model) ->  SignalProducer<Model, Error>
    
    func hasPersistenceExpired() -> SignalProducer<Bool, NoError>
}

public typealias InDiskPersistence = protocol<InDiskElementPersistence, InDiskElementsPersistence>

public final class InDiskPersistenceHandler<T where T: Mappable> : InDiskPersistence {
    
    private let persistenceFilePath: String
    private let expirationTime: NSTimeInterval
    
    public init(persistenceFilePath: String, expirationTime: NSTimeInterval = 2) {
        
        self.persistenceFilePath = persistenceFilePath
        self.expirationTime = expirationTime
    }
    
    public func load() -> SignalProducer<T, Error> {
        return readFileData(persistenceFilePath)
            .flatMapLatest(parse)
    }
    
    public func load() -> SignalProducer<[T], Error> {
        return readFileData(persistenceFilePath)
            .flatMapLatest(parse)
    }
    
    public func save(model: T) -> SignalProducer<T, Error> {
        
        let writeData = curry(writeToFile)(persistenceFilePath)
        
        return encode(model)
            .flatMapLatest(writeData)
            .map { _ in model }
    }
    
    public func save(models: [T]) ->  SignalProducer<[T], Error> {
        
        let writeData = curry(writeToFile)(persistenceFilePath)
        
        return encode(models)
            .flatMapLatest(writeData)
            .map { _ in models }
    }
    
    public func hasPersistenceExpired() -> SignalProducer<Bool, NoError> {
        
        let didExpire = flip(curry(didCacheExpired))(expirationTime)
        return fileCreationDate(persistenceFilePath)
            .flatMapLatest{ SignalProducer(value: $0) }
            .flatMapLatest(didExpire)
            .flatMapError{ _ in SignalProducer(value: true) }
    }
}
