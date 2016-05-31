//
//  Persistence.swift
//  Reactor
//
//  Created by Rui Peres on 21/07/2015.
//  Copyright © 2015 Mail Online. All rights reserved.
//

import Result
import ReactiveCocoa

func writeToFile(fullPath: String, data: NSData) -> SignalProducer<NSData, Error> {
    
    return SignalProducer { o, d in
        do
        {
            try data.writeToFile(fullPath, options: [.DataWritingAtomic])
            
            o.sendNext(data)
            o.sendCompleted()
        }
        catch {
            o.sendFailed(.Persistence("writeToFile error \(fullPath)"))
        }
    }
}

func readFileData(fullPath: String) -> SignalProducer<NSData, Error> {
    return SignalProducer { o, d in
        do
        {
            let data = try NSData(contentsOfFile: fullPath, options: [.DataReadingUncached])
            o.sendNext(data)
            o.sendCompleted()
        }
        catch {
            o.sendFailed(.Persistence("readFileData error \(fullPath)"))
        }
    }
}

func fileCreationDate(fullPath: String) -> SignalProducer<NSDate, Error> {
    return SignalProducer { o, d in
        do
        {
            let attributes = try NSFileManager.defaultManager().attributesOfItemAtPath(fullPath)
            if let creationDate = attributes[NSFileCreationDate] as? NSDate {
                o.sendNext(creationDate)
                o.sendCompleted()
            }
            else {
                o.sendFailed(.Persistence("No creation date found for file \(fullPath)"))
            }
        }
        catch {
            o.sendFailed(.Persistence("Couldn't get file attributes \(fullPath)"))
        }
    }
}

func doesFileExists(fullPath: String) -> SignalProducer<Bool, NoError> {
    return SignalProducer { o, d in
        o.sendNext(NSFileManager().fileExistsAtPath(fullPath))
        o.sendCompleted()
    }   
}

func appendRelativePathToRoot(relativePath: String, rootPath: String = documentsRootPath) -> String {
    return (rootPath as NSString).stringByAppendingPathComponent(relativePath)
}

let documentsRootPath: String = {
    return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
    }()

func dateLaterThan(date: NSDate, seconds: NSTimeInterval) -> Bool {
    return abs(date.timeIntervalSinceNow) > seconds
}

func didCacheExpired(date: NSDate, laterThan seconds: NSTimeInterval) -> SignalProducer<Bool, Error> {
    return SignalProducer {o, d in
        let laterThan = dateLaterThan(date, seconds: seconds)
        
        o.sendNext(laterThan)
        o.sendCompleted()
    }
}
