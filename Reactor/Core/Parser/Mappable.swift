//
//  Mappable.swift
//  Reactor
//
//  Created by Rui Peres on 13/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import Result

public enum MappedError: ErrorType {
    case Custom(String)
}

public protocol Mappable {
    
    static func mapToModel(o: AnyObject) -> Result<Self, MappedError>
    func mapToJSON() -> AnyObject
}