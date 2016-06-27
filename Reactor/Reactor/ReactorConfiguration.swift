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
    /// If reachability should be used.
    /// `true` by default.
    var shouldCheckReachability: Bool { get }
    /// If the parser should be strict or prune the bad objects.
    /// Pruning will simply remove objects that are not parseable, instead
    /// of erroring the flow. Strict on the other hand as soon as it finds
    /// a bad object will error the entire flow.
    /// Note: if you receive an entire batch of bad objects, it will default to
    /// an empty array. Witch leads to not knowing if the server has no results or
    /// all objects are badly formed.
    /// `true` by default.
    var shouldPrune: Bool { get }
}

//public typealias PathToPersistence = String
//public enum PersistenceConfiguration {
//    case Enabled(withPath: PathToPersistence)
//    case Disabled
//}

extension FlowConfiguration: FlowConfigurable {}

/// Configuration object to customize the Reactor's behaviour
public struct FlowConfiguration {

//    public var persistenceConfiguration: PersistenceConfiguration
    public var shouldCheckReachability: Bool = true
    public var shouldPrune: Bool = true
    
//    public init(persistenceConfiguration: PersistenceConfiguration) {
//        self.persistenceConfiguration = persistenceConfiguration
//    }
}
