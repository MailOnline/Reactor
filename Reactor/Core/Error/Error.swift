//
//  Error.swift
//  Reactor
//
//  Created by Rui Peres on 12/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

public enum ReactorError: Error {
    
    case server(String)
    case noConnectivity
    case persistence(String)
    case parser(String)
}

extension ReactorError: Equatable {}

public func == (lhs: ReactorError, rhs: ReactorError) -> Bool {
    
    switch(lhs, rhs) {
    case (.server, .server): return true
    case (.noConnectivity, .noConnectivity): return true
    case (.parser, .parser): return true
    case (.persistence, .persistence): return true
    default: return false
    }
}
