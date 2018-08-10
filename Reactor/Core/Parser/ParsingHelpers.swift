import Result

func strictArrayFromJSON<T: Mappable>(_ objects: [AnyObject]) -> Result<[T], ReactorError> {
    
    var convertAndCleanArray: [T] = []
    
    for object in objects {
        
        let mappedModel = T.mapToModel(object)
        
        guard case .success(let model) = mappedModel else { return mappedModel.map { _ in [] }.mapError { .parser($0.description) } }
        convertAndCleanArray.append(model)
    }
    
    return Result(value: convertAndCleanArray)
}

func prunedArrayFromJSON<T: Mappable>(_ objects: [AnyObject]) -> Result<[T], ReactorError> {
    
    var convertAndCleanArray: [T] = []
    
    for object in objects {
        
        guard case .success(let model) = T.mapToModel(object) else { continue }
        convertAndCleanArray.append(model)
    }
    
    return Result(value: convertAndCleanArray)
}

func prunedArrayFromJSON<T: Mappable>(_ anyObject: AnyObject, key: String) -> Result<[T], ReactorError> {
    
    guard
        let dictionary = anyObject as? [String: AnyObject],
        let objects = dictionary[key] as? [AnyObject] else { return Result(value: []) }
    
    return prunedArrayFromJSON(objects)
}
