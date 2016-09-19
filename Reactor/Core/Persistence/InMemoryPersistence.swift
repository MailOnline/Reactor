//
//  InMemoryPersistence.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import Result
import ReactiveSwift

protocol InMemoryElementsPersistence {
    
    associatedtype Model: Hashable

    func load(_ hash: Int) -> SignalProducer<Model, ReactorError>
    func save(_ model: Model) ->  SignalProducer<Model, ReactorError>
}

protocol InMemoryElementPersistence {
    
    associatedtype Model: Hashable
    
    func load() -> SignalProducer<[Model], ReactorError>
    func save(_ models: [Model]) ->  SignalProducer<[Model], ReactorError>
}

typealias InMemoryPersistence = (InMemoryElementPersistence & InMemoryElementsPersistence)

final class InMemoryPersistenceHandler<T>: InMemoryPersistence where T: Hashable {
    
    private let cache: Cache<T>
    
    init(cache: Cache<T>) {
        
        self.cache = cache
    }
    
    func load(_ hash: Int) -> SignalProducer<T, ReactorError> {

        return SignalProducer {[weak self] observer, disposable in
            
            guard let object = self?.cache[hash]
                else {
                    observer.send(error: .persistence("file not found in cache"))
                    return
            }

            observer.send(value: object)
            observer.sendCompleted()
        }
    }
    
    func load() -> SignalProducer<[T], ReactorError> {
        
        return SignalProducer(value: cache.all())
    }
    
    func save(_ object: T) -> SignalProducer<T, ReactorError> {
        
        return SignalProducer {[weak self] observer, disposable in
            
            self?.cache[object.hashValue] = object
            
            observer.send(value: object)
            observer.sendCompleted()
        }
    }
    
    func save(_ objects: [T]) -> SignalProducer<[T], ReactorError> {
        
        return SignalProducer {[weak self] observer, disposable in
            
            objects.forEach { item in
                self?.cache[item.hashValue] = item
            }
            observer.send(value: objects)
            observer.sendCompleted()
        }
    }
}
