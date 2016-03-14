//
//  InMemoryPersistence.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import Result
import ReactiveCocoa

public protocol InMemoryElementsPersistence {
    
    typealias Model: Hashable

    func load(hash: Int) -> SignalProducer<Model, Error>
    func save(model: Model) ->  SignalProducer<Model, Error>
}

public protocol InMemoryElementPersistence {
    
    typealias Model: Hashable
    
    func load() -> SignalProducer<[Model], Error>
    func save(models: [Model]) ->  SignalProducer<[Model], Error>
}

public typealias InMemoryPersistence = protocol <InMemoryElementPersistence, InMemoryElementsPersistence>

public final class InMemoryPersistenceHandler<T where T: Hashable>: InMemoryPersistence {
    
    private let cache: Cache<T>
    
    public init(cache: Cache<T>) {
        
        self.cache = cache
    }
    
    public func load(hash: Int) -> SignalProducer<T, Error> {
        
        return SignalProducer {[weak self] observer, disposable in
            
            guard let object = self?.cache[hash]
                else {
                    observer.sendFailed(.Persistence("file not found in cache"))
                    return
            }
            
            observer.sendNext(object)
            observer.sendCompleted()
        }
    }
    
    public func load() -> SignalProducer<[T], Error> {
        
        return SignalProducer(value: cache.all())
    }
    
    public func save(object: T) -> SignalProducer<T, Error> {
        
        return SignalProducer {[weak self] observer, disposable in
            
            self?.cache[object.hashValue] = object
            
            observer.sendNext(object)
            observer.sendCompleted()
        }
    }
    
    public func save(objects: [T]) -> SignalProducer<[T], Error> {
        
        return SignalProducer {[weak self] observer, disposable in
            
            objects.forEach { item in
                self?.cache[item.hashValue] = item
            }
            observer.sendNext(objects)
            observer.sendCompleted()
        }
    }
}
