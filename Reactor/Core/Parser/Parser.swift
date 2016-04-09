//
//  Parser.swift
//  Reactor
//
//  Created by Rui Peres on 13/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import ReactiveCocoa
import Result

func parse<T where T: Mappable>(data: NSData) -> SignalProducer<T, Error> {
    
    return SignalProducer.attempt {
        
        let decodedData: Result<AnyObject, Error> = decodeData(data)
        return decodedData.flatMap { T.mapToModel($0).mapError { .Parser($0.description) } }
    }
}

func parse<T where T: SequenceType, T.Generator.Element: Mappable>(data: NSData) -> SignalProducer<T, Error> {

    let toArray: [AnyObject] -> [T.Generator.Element] = arrayFromJSON
    
    return SignalProducer.attempt {
        
        let decodedData: Result<AnyObject, Error> = decodeData(data)
        
        // the `.map { $0 as! T}` is horrible, but it's the only way for it to accept it. 
        // I am 100% sure it will always pass. :/
        return decodedData.flatMap { Result($0 as? [AnyObject], failWith: .Parser("\($0) is not an Array")) }.map(toArray).map { $0 as! T}
    }
}

func encode<T where T: Mappable>(item: T) -> SignalProducer<NSData, Error> {
    
    return encode(item.mapToJSON())
}

func encode<T where T: SequenceType, T.Generator.Element: Mappable>(items: T) -> SignalProducer<NSData, Error> {
    
    return encode(items.map {$0.mapToJSON()})
}

private func encode(object: AnyObject) -> SignalProducer<NSData, Error> {
    
    let result: Result<NSData, NSError> = Result { try NSJSONSerialization.dataWithJSONObject(object, options: NSJSONWritingOptions.PrettyPrinted) }
    return SignalProducer(result: result.mapError { .Parser($0.description) })
}

func decodeData(data: NSData) -> Result<AnyObject, Error> {
    
    let result = Result<AnyObject, NSError> { try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) }
    return result.mapError { .Parser($0.description) }
}