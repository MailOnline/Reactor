//
//  Reactor.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import ReactiveCocoa

struct ReactorConfiguration<T: Mappable> {
    
    let inDiskPersistentHandler: InDiskPersistenceHandler<T>
    let connection: Connection
    let parser: NSData -> SignalProducer<[T], Error> = parse
}

struct Reactor<T: Mappable> {
    
    private let information: ReactorConfiguration<T>
    
    init(information: ReactorConfiguration<T>) {
        
        self.information = information
    }
    
    func fetch(resource: Resource) -> SignalProducer<[T], Error> {
        
        let inDiskPersistentHandler = information.inDiskPersistentHandler
        
        let experitationHandler: Bool -> SignalProducer <[T], Error> = { hasExpired in
            
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
    
    func fetchFromNetwork(resource: Resource) -> SignalProducer<[T], Error> {
        
        let connection = information.connection
        let parser = information.parser
        
        return connection.makeRequest(resource).map { $0.0 }.flatMapLatest(parser)
    }
}
