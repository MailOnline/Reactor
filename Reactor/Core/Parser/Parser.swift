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
    
    return SignalProducer { o, d in
        let decodedData: Result<AnyObject, Error> = decodeData(data)
        
        guard
            case .Success(let decoded) = decodedData,
            case .Success(let item) = T.mapToModel(decoded)
            else { o.sendFailed(.Parser); return }
        
        o.sendNext(item)
        o.sendCompleted()
    }
}

func parse<T where T: SequenceType, T.Generator.Element: Mappable>(data: NSData) -> SignalProducer<T, Error> {
    
    return SignalProducer { o, d in
                
        let decodedData: Result<AnyObject, Error> = decodeData(data)
        
        guard
            case .Success(let decoded) = decodedData,
            let array = decoded as? [AnyObject],
            let items: [T.Generator.Element] = arrayFromJSON(array)
            else { o.sendFailed(.Parser); return }
        
        o.sendNext(items as! T)
        o.sendCompleted()
    }
}

func encode<T where T: Mappable>(item: T) -> SignalProducer<NSData, Error> {
    
    return encode(item.mapToJSON())
}

func encode<T where T: SequenceType, T.Generator.Element: Mappable>(items: T) -> SignalProducer<NSData, Error> {
    
    return encode(items.map {$0.mapToJSON()})
}

private func encode(object: AnyObject) -> SignalProducer<NSData, Error> {
    
    return SignalProducer { o, d in
        do
        {
            let data: NSData = try NSJSONSerialization.dataWithJSONObject(object, options: NSJSONWritingOptions.PrettyPrinted)
            o.sendNext(data)
            o.sendCompleted()
        }
        catch {
            o.sendFailed(.Parser)
        }
    }
}

func decodeData(data: NSData) -> Result<AnyObject, Error> {
    
    do {
        let parsedData = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
        return Result(value: parsedData)
    }
    catch {
        return Result(error: .Parser)
    }
}
