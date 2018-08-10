import Result
import ReactiveSwift

func writeToFile(_ fullPath: String, data: Data) -> SignalProducer<Data, ReactorError> {
    
    return SignalProducer { o, d in
        do
        {
            try data.write(to: URL(fileURLWithPath: fullPath), options: [.atomic])
            
            o.send(value: data)
            o.sendCompleted()
        }
        catch {
            o.send(error: .persistence("writeToFile error \(fullPath)"))
        }
    }
}

func readFileData(_ fullPath: String) -> SignalProducer<Data, ReactorError> {
    return SignalProducer { o, d in
        do
        {
            let data = try Data(contentsOf: URL(fileURLWithPath: fullPath), options: [.uncached])
            o.send(value: data)
            o.sendCompleted()
        }
        catch {
            o.send(error: .persistence("readFileData error \(fullPath)"))
        }
    }
}

func fileCreationDate(_ fullPath: String) -> SignalProducer<Date, ReactorError> {
    return SignalProducer { o, d in
        do
        {
            let attributes = try FileManager.default.attributesOfItem(atPath: fullPath)
            if let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
                o.send(value: creationDate)
                o.sendCompleted()
            }
            else {
                o.send(error: .persistence("No creation date found for file \(fullPath)"))
            }
        }
        catch {
            o.send(error: .persistence("Couldn't get file attributes \(fullPath)"))
        }
    }
}

func doesFileExists(_ fullPath: String) -> SignalProducer<Bool, NoError> {
    return SignalProducer { o, d in
        o.send(value: FileManager().fileExists(atPath: fullPath))
        o.sendCompleted()
    }   
}

func appendRelativePathToRoot(_ relativePath: String, rootPath: String = documentsRootPath) -> String {
    return (rootPath as NSString).appendingPathComponent(relativePath)
}

let documentsRootPath: String = {
    return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    }()

func dateLaterThan(_ date: Date, seconds: TimeInterval) -> Bool {
    return abs(date.timeIntervalSinceNow) > seconds
}

func didCacheExpired(_ date: Date, laterThan seconds: TimeInterval) -> SignalProducer<Bool, ReactorError> {
    return SignalProducer {o, d in
        let laterThan = dateLaterThan(date, seconds: seconds)
        
        o.send(value: laterThan)
        o.sendCompleted()
    }
}
