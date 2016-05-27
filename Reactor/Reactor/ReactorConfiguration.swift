//
//  ReactorConfiguration.swift
//  Reactor
//
//  Created by Rui Peres on 21/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

public protocol CoreConfigurable {
    /// If the entire flow should fail, when `saveToPersistenceFlow` fails.
    /// `true` by default.
    var shouldFailWhenSaveToPersistenceFails: Bool { get }
    /// If the `saveToPersistenceFlow`, should be part of the flow.
    /// Should be `false` when the flow shouldn't
    /// wait for `saveToPersistenceFlow` to finish (for example it takes
    /// a long time).
    /// Note: if you set it as `false` and it fails, the failure will be
    /// lost, because it's not part of the flow, but injected instead .
    /// `true` by default.
    var shouldWaitForSaveToPersistence: Bool { get }
}

extension CoreConfiguration: CoreConfigurable {}

/// Configuration object to customize the Reactor's behaviour
public struct CoreConfiguration {
    
    public var shouldFailWhenSaveToPersistenceFails: Bool = true
    public var shouldWaitForSaveToPersistence: Bool = true
}

public protocol FlowConfigurable {
    /// If persistence should be used.
    /// If it should a path needs to be provided. 
    var usingPersistence: ShouldUsePersistence { get }
    /// If reachability should be used.
    /// `true` by default.
    var shouldCheckReachability: Bool { get }
    /// If the parser should be strick or prune the bad objects.
    /// Prunning will simply remove objects are were not parsable, instead
    /// of erroring the flow. Strick on the other hand as soon as it finds
    /// a bad objects will error the entire flow.
    /// Note: if you receive an entire batch of bad objects, it will default to
    /// an empty array. Witch leads to not knowing if the server has no results or
    /// all objects are badly formed.
    /// `true` by default.
    var shouldPrune: Bool { get }
}

public typealias PathToPersistence = String
public enum ShouldUsePersistence {
    case Yes(withPath: PathToPersistence)
    case No
}

extension FlowConfiguration: FlowConfigurable {}

/// Configuration object to customize the Reactor's behaviour
public struct FlowConfiguration {

    public var usingPersistence: ShouldUsePersistence
    public var shouldCheckReachability: Bool = true
    public var shouldPrune: Bool = true
    
    public init(usingPersistence: ShouldUsePersistence) {
        self.usingPersistence = usingPersistence
    }
}
