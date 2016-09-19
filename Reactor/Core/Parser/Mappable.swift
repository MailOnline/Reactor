//
//  Mappable.swift
//  Reactor
//
//  Created by Rui Peres on 13/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import Result

/// This should be used when there is an error at the parsing level for better debugging
public enum MappedError: Error {
    case custom(String)
    
    var description: String {
        switch self {
        case .custom(let description): return description
        }
    }
}

/// Used to represent an object that can be converted 
/// from `AnyObject` (Dictionary) from and to Itself
public protocol Mappable {
    
    /// Converts the object from a `AnyObject` (Dictionary) to Itself.
    static func mapToModel(_ o: AnyObject) -> Result<Self, MappedError>
    
    /// Converts the object from a `AnyObject` (Dictionary) to Itself.
    /// You can simply return `NSNull()` if it doesn't make sense in your context to do that.
    /// This is used for persisting the object in disk.
    func mapToJSON() -> AnyObject
}
