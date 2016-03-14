//
//  Error.swift
//  Reactor
//
//  Created by Rui Peres on 12/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

public enum Error: ErrorType {
    
    case Server(String)
    case NoConnectivity
    case Persistence(String)
    case Parser
}

extension Error: Equatable {}

public func == (lhs: Error, rhs: Error) -> Bool {
    
    switch(lhs, rhs) {
    case (.Server, .Server): return true
    case (.NoConnectivity, .NoConnectivity): return true
    case (.Parser, .Parser): return true
    case (.Persistence, .Persistence): return true
    default: return false
    }
}