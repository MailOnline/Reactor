//
//  InDiskPersistence.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import Result
import ReactiveCocoa

extension InDiskPersistenceHandler where T: Mappable {
    
    /// Used to load a single `Mappable` element from persistence
    public func load(path: String) -> SignalProducer<T, Error> {
        return readFileData(path)
            .flatMapLatest(parse)
    }
    
    /// Used to save to persistence a single `Mappable` element into persistence
    /// The model is returned back when saved.
    public func save(path: String, model: T) ->  SignalProducer<T, Error> {
        
        let writeData = curry(writeToFile)(path)
        
        return encode(model)
            .flatMapLatest(writeData)
            .map { _ in model }
    }
}

extension InDiskPersistenceHandler where T: SequenceType, T.Generator.Element: Mappable {
    
    /// Used to load a Sequence of `Mappable` elements from persistence
    public func load(path: String, parser: NSData -> SignalProducer<T, Error> = prunedParse) -> SignalProducer<T, Error> {
        
        return readFileData(path)
            .flatMapLatest(parser)
    }
    
    /// Used to save to persistence a Sequence of `Mappable` elements into persistence
    /// The models are returned back when saved.
    public func save(path: String, models: T) ->  SignalProducer<T, Error> {
        
        let writeData = curry(writeToFile)(path)
        
        return encode(models)
            .flatMapLatest(writeData)
            .map { _ in models }
    }
}

/// Used to persist a `T` in disk. The `T` or the `Sequence.Generator.Element` must be `Mappable`, in order for it work
public final class InDiskPersistenceHandler<T> {
    
    /// Check if a file has experied. The expiration time is based on the 
    /// TimeInterval passed when the InDiskPersistenceHandler is created
    public func hasPersistenceExpired(path: String, expirationTime: NSTimeInterval = 2) -> SignalProducer<Bool, NoError> {
        
        let didExpire = flip(curry(didCacheExpired))(expirationTime)
        return fileCreationDate(path)
            .flatMapLatest{ SignalProducer(value: $0) }
            .flatMapLatest(didExpire)
            .flatMapError{ _ in SignalProducer(value: true) }
    }
}
