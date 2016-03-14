//
//  Reactor.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import ReactiveCocoa

struct ReactorConfiguration<T: InDiskElementsPersistence where T.Model: Mappable> {
    
    let inDiskPersistentHandler: T
    let connection: Connection
    let parser: NSData -> SignalProducer<[T.Model], Error> = parse
}

struct Reactor<T: InDiskElementsPersistence where T.Model: Mappable> {
    
    typealias Model = T.Model
    
    private let information: ReactorConfiguration<T>
    
    init(information: ReactorConfiguration<T>) {
        
        self.information = information
    }
    
    func fetch(resource: Resource) -> SignalProducer<[Model], Error> {
        
        let inDiskPersistentHandler = information.inDiskPersistentHandler
        
        let experitationHandler: Bool -> SignalProducer <[Model], Error> = { hasExpired in
            
            if hasExpired {
                return self.fetchFromNetwork(resource)
            }
            else {
                return inDiskPersistentHandler.load()
            }
        }
        
        return inDiskPersistentHandler.hasPersistenceExpired()
            .flatMapError { _ in SignalProducer(error: Error.Persistence("")) }
            .flatMapLatest(experitationHandler)
    }
    
    func fetchFromNetwork(resource: Resource) -> SignalProducer<[Model], Error> {
        
        let inDiskPersistentHandler = information.inDiskPersistentHandler.save
        let connection = information.connection
        let parser = information.parser
        
        return connection.makeRequest(resource).map { $0.0 }
            .flatMapLatest(parser)
            .flatMapLatest(inDiskPersistentHandler)
    }
}
