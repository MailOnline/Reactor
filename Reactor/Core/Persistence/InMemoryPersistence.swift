//
//  InMemoryPersistence.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import Result
import ReactiveCocoa

protocol InMemoryElementsPersistence {
    
    typealias Model: Hashable

    func load(hash: Int) -> SignalProducer<Model, Error>
    func save(model: Model) ->  SignalProducer<Model, Error>
}

protocol InMemoryElementPersistence {
    
    typealias Model: Hashable
    
    func load() -> SignalProducer<[Model], Error>
    func save(models: [Model]) ->  SignalProducer<[Model], Error>
}

typealias InMemoryPersistence = protocol <InMemoryElementPersistence, InMemoryElementsPersistence>

final class InMemoryPersistenceHandler<T where T: Hashable>: InMemoryPersistence {
    
    private let cache: Cache<T>
    
    init(cache: Cache<T>) {
        
        self.cache = cache
    }
    
    func load(hash: Int) -> SignalProducer<T, Error> {
        
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
    
    func load() -> SignalProducer<[T], Error> {
        
        return SignalProducer(value: cache.all())
    }
    
    func save(object: T) -> SignalProducer<T, Error> {
        
        return SignalProducer {[weak self] observer, disposable in
            
            self?.cache[object.hashValue] = object
            
            observer.sendNext(object)
            observer.sendCompleted()
        }
    }
    
    func save(objects: [T]) -> SignalProducer<[T], Error> {
        
        return SignalProducer {[weak self] observer, disposable in
            
            objects.forEach { item in
                self?.cache[item.hashValue] = item
            }
            observer.sendNext(objects)
            observer.sendCompleted()
        }
    }
}
