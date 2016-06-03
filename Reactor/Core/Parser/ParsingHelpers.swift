//
//  ParsingHelpers.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import Result
import Foundation

public func strictArrayFromJSON<T: Mappable>(objects: [AnyObject]) -> Result<[T], Error> {
    
    var convertAndCleanArray: [T] = []
    
    for object in objects {
        
        let mappedModel = T.mapToModel(object)
        
        guard case .Success(let model) = mappedModel else { return mappedModel.map { _ in [] }.mapError { .Parser($0.description) } }
        convertAndCleanArray.append(model)
    }
    
    return Result(value: convertAndCleanArray)
}

public func prunedArrayFromJSON<T: Mappable>(objects: [AnyObject]) -> Result<[T], Error> {
    
    var convertAndCleanArray: [T] = []
    
    for object in objects {
        
        guard case .Success(let model) = T.mapToModel(object) else { continue }
        convertAndCleanArray.append(model)
    }
    
    return Result(value: convertAndCleanArray)
}

public func prunedArrayFromJSON<T: Mappable>(anyObject: AnyObject, key: String) -> Result<[T], Error> {
    
    guard
        let dictionary = anyObject as? [String: AnyObject],
        let objects = dictionary[key] as? [AnyObject] else { return Result(value: []) }
    
    return prunedArrayFromJSON(objects)
}

public func arrayToJSON<T: Mappable>(input: [T]) -> AnyObject {
    
    var a: [AnyObject] = []
    
    for i in input {
        
        let o = i.mapToJSON()
        a.append(o)
        
    }
    
    return a
}

public func injectKey<T: Mappable>(value: T, k: String) -> AnyObject {
    
    guard
        var a = value.mapToJSON() as? [String: AnyObject]
        else { return NSNull() }
    
    a["type"] = k
    
    return a
}
