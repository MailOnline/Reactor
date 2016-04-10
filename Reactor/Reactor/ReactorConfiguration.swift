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
    public var flowShouldFailWhenSaveToPersistenceFails: Bool = true
    /// If the `saveToPersistenceFlow`, should be part of the flow.
    /// By default `true`. Should be `false` when the flow shouldn't
    /// wait for `saveToPersistenceFlow` to finish (for example it takes 
    /// a long time).
    /// Note: if you set it as `false` and it fails, the failure will be 
    /// lost, because it's not part of the flow, but instead injected.
    public var shouldWaitForSaveToPersistence: Bool = true
    /// If the parser should be strick or prune the bad objects.
    /// Prunning will simply remove objects are were not parsable, instead
    /// of erroring the flow. Strick on the other hand as soon as it finds
    /// a bad objects will error the entire flow
    /// By default it prune.
    public var shouldPrune: Bool = true
}