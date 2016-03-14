//
//  Reactor.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import ReactiveCocoa

struct Information<T: InDiskElementsPersistence where T.Model: Mappable> {
    
    let inDiskPersistentHandler: T
    let experitationInMinutes: NSTimeInterval
    
    let connection: Connection
    let parser: NSData -> SignalProducer<[T.Model], Error> = parse
}

struct Reactor<T: InDiskElementsPersistence where T.Model: Mappable> {
    
    typealias Model = T.Model
    
    private let information: Information<T>
    
    init(information: Information<T>) {
        
        self.information = information
    }
    
    func fetch(resource: Resource) -> SignalProducer<[Model], Error> {
        
        let experitationTime = information.experitationInMinutes
        let inDiskPersistentHandler = information.inDiskPersistentHandler
        
        let experitationHandler: Bool -> SignalProducer <[Model], Error> = { hasExpired in
            
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
    
    func fetchFromNetwork(resource: Resource) -> SignalProducer<[Model], Error> {
        
        let connection = information.connection
        let parser = information.parser
        
        return connection.makeRequest(resource).map { $0.0 }.flatMapLatest(parser)
    }
}
