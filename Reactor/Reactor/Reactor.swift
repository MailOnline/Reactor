//
//  Reactor.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import ReactiveCocoa

struct Information<T: Mappable> {
    
    let inDiskPersistentHandler: InDiskPersistenceHandler<T>
    let experitationInMinutes: NSTimeInterval
    
    let connection: Connection
    let parser: NSData -> SignalProducer<[T], Error> = parse
}

struct Reactor<T: Mappable> {
    
    private let information: Information<T>
    
    init(information: Information<T>) {
        
        self.information = information
    }
    
    func fetch(resource: Resource) -> SignalProducer<[T], Error> {
        
        let experitationTime = information.experitationInMinutes
        let inDiskPersistentHandler = information.inDiskPersistentHandler
        
        let experitationHandler: Bool -> SignalProducer <[T], Error> = { hasExpired in
            
            if hasExpired {
                return self.fetchFromNetwork(resource)
            }
            else {
                return inDiskPersistentHandler.load()
            }
        }
        
        return inDiskPersistentHandler.hasPersistenceExpired(expirationInSeconds: experitationTime)
            .flatMapError { _ in SignalProducer(error: Error.Persistence("")) }
            .flatMapLatest(experitationHandler)
    }
    
    func fetchFromNetwork(resource: Resource) -> SignalProducer<[T], Error> {
        
        let connection = information.connection
        let parser = information.parser
        
        return connection.makeRequest(resource).map { $0.0 }.flatMapLatest(parser)
    }
}
