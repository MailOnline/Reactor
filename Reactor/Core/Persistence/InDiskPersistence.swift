//
//  InDiskPersistence.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import Result
import ReactiveCocoa

public final class InDiskPersistenceHandler<T where T: Mappable> { 
    
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
    
    public func hasPersistenceExpired(expirationInSeconds seconds: NSTimeInterval) -> SignalProducer<Bool, NoError> {
        
        let didExpire = flip(curry(didCacheExpired))(seconds)
        return fileCreationDate(persistenceFilePath)
            .flatMapLatest{ SignalProducer(value: $0) }
            .flatMapLatest(didExpire)
            .flatMapError{ _ in SignalProducer(value: true) }
    }
}
