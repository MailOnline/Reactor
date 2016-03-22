//
//  ReactorConfiguration.swift
//  Reactor
//
//  Created by Rui Peres on 21/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

/// Configuration object to customize the Reactor's behaviour
public struct ReactorConfiguration {

    /// If persistence should be used
    public var usingPersistence: Bool = true
    /// If reachability should be used
    public var shouldCheckReachability: Bool = true
    /// If the entire flow should fail, when `saveToPersistenceFlow` fails  
    public var shouldFailWhenSaveToPersistenceFails: Bool = true
}