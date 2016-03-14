//
//  ParsingHelpers.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import Foundation

func arrayFromJSON<T: Mappable>(objects: [AnyObject]) -> [T] {
    
    var convertAndCleanArray: [T] = []
    
    for object in objects {
        
        guard case .Success(let model) = T.mapToModel(object) else { continue }
        convertAndCleanArray.append(model)
    }
    
    return convertAndCleanArray
}

func arrayFromJSON<T: Mappable>(anyObject: AnyObject, key: String) -> [T] {
    
    guard let objects = anyObject[key] as? [AnyObject] else { return [] }
    return arrayFromJSON(objects)
}