//import ReactiveSwift
//import Result
//
//public func parse<T>(_ data: Data) -> SignalProducer<T, ReactorError> where T: Mappable {
//    
//    return SignalProducer.attempt {
//        
//        let decodedData: Result<AnyObject, ReactorError> = decodeData(data)
//        return decodedData.flatMap { T.mapToModel($0).mapError { .parser($0.description) } }
//    }
//}
//
//public func parse<T>(_ data: Data, toArray: @escaping ([AnyObject]) -> Result<[T.Iterator.Element], ReactorError>) -> SignalProducer<T, ReactorError> where T: Sequence, T.Iterator.Element: Mappable {
//    
//    return SignalProducer.attempt {
//        
//        let decodedData: Result<AnyObject, ReactorError> = decodeData(data)
//        
//        // the `.map { $0.value as! T}` is horrible, but it's the only way for the compiler to accept it.
//        // I am 100% sure it will always pass. 😅
//        return decodedData.flatMap { Result($0 as? [AnyObject], failWith: .parser("\($0) is not an Array")) }.flatMap(toArray).map { $0 as! T }
//    }
//}
//
//public func prunedParse<T>(_ data: Data) -> SignalProducer<T, ReactorError> where T: Sequence, T.Iterator.Element: Mappable {
//    
//    return parse(data, toArray: prunedArrayFromJSON)
//}
//
//public func strictParse<T>(_ data: Data) -> SignalProducer<T, ReactorError> where T: Sequence, T.Iterator.Element: Mappable {
//    
//    return parse(data, toArray: strictArrayFromJSON)
//}
//
//func encode<T>(_ item: T) -> SignalProducer<Data, ReactorError> where T: Mappable {
//
//    return encode(item.mapToJSON())
//}
//
//func encode<T>(_ items: T) -> SignalProducer<Data, ReactorError> where T: Sequence, T.Iterator.Element: Mappable {
//
//    let f: (T.Iterator.Element) -> AnyObject = { $0.mapToJSON() }
//    return encode(items.map(f) as AnyObject)
//}
//
//private func encode(_ object: AnyObject) -> SignalProducer<Data, ReactorError> {
//    
//    let result: Result<Data, NSError> = Result { try JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions.prettyPrinted) }
//    return SignalProducer(result: result.mapError { .parser($0.description) })
//}
//
//func decodeData(_ data: Data) -> Result<AnyObject, ReactorError> {
//    
//    let result = Result<AnyObject, NSError> {
//        try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as AnyObject
//    }
//    return result.mapError { .parser($0.description) }
//}
