//
//  ModelsPersistence.swift
//  Reactor
//
//  Created by Rui Peres on 06/11/2015.
//  Copyright © 2015 Mail Online. All rights reserved.
//

import Result
import ReactiveCocoa

//MARK: - Feed Item Persistence (in memory)

public final class PersistenceHandler<InMemory: InMemoryPersistence, InDisk: InDiskPersistence> {
    
    public let inMemoryPersistence: InMemory
    public let inDiskPersistence: InDisk
    
    public init(inMemoryPersistence: InMemory, inDiskPersistence: InDisk) {
        
        self.inMemoryPersistence = inMemoryPersistence
        self.inDiskPersistence = inDiskPersistence
    }
}
