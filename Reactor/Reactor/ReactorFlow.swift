//import Result
//import ReactiveSwift
//
///// Used to represent the ReactorFlow. A typical flow consists of loading from persistence,
///// making a network request and finally saving it to persistence. All three flows are
///// public on purpose, so they can be manually replaced or extended.
/////
///// At very least a `NetworkFlow` must be provided, at initialization.
//public struct ReactorFlow<T> {
//    
//    public typealias NetworkFlow = (Resource) -> SignalProducer<T, ReactorError>
//    public typealias LoadFromPersistenceFlow = () -> SignalProducer<T, ReactorError>
//    public typealias SaveToPersistenceFlow = (T) -> SignalProducer<T, ReactorError>
//    
//    public var networkFlow: NetworkFlow
//    public var loadFromPersistenceFlow: LoadFromPersistenceFlow
//    public var saveToPersistenceFlow: SaveToPersistenceFlow
//    
//    /// If `loadFromPersistenceFlow` is not passed, the `Reactor` will bailout and hit the network
//    /// If `saveToPersistenceFlow` is not passed, the `Reactor` will persist anything
//    init(networkFlow: @escaping NetworkFlow, loadFromPersistenceFlow: @escaping LoadFromPersistenceFlow = {SignalProducer(error: .persistence("Persistence bailout"))}, saveToPersistenceFlow: @escaping SaveToPersistenceFlow = SignalProducer.identity) {
//        
//        self.networkFlow = networkFlow
//        self.loadFromPersistenceFlow = loadFromPersistenceFlow
//        self.saveToPersistenceFlow = saveToPersistenceFlow
//    }
//}
//
///// Used as a factory to create a `ReactorFlow` for a single `T: Mappable`
//public func createFlow<T>(_ connection: Connection, configuration: FlowConfigurable = FlowConfiguration(persistenceConfiguration: .disabled)) -> ReactorFlow<T> where T: Mappable {
//    
//    let parser: (Data) -> SignalProducer<T, ReactorError> = parse
//    let networkFlow: (Resource) -> SignalProducer<T, ReactorError> = { resource in connection.makeRequest(resource).map { $0.0}.flatMapLatest(parser) }
//    
//    switch configuration.persistenceConfiguration {
//    case .disabled:
//        return ReactorFlow(networkFlow: networkFlow)
//        
//    case .enabled(let persistencePath):
//        let persistenceHandler = InDiskPersistenceHandler<T>(persistenceFilePath: persistencePath)
//        let loadFromPersistence = persistenceHandler.load
//        let saveToPersistence =  persistenceHandler.save
//        
//        return ReactorFlow(networkFlow: networkFlow, loadFromPersistenceFlow: loadFromPersistence, saveToPersistenceFlow: saveToPersistence)
//    }
//}
//
///// Used as a factory to create a `ReactorFlow` for a single `T: Mappable`
//public func createFlow<T>(_ baseURL: URL, configuration: FlowConfigurable = FlowConfiguration(persistenceConfiguration: .disabled)) -> ReactorFlow<T> where T: Mappable {
//    
//    let connection = createConnection(baseURL, shouldCheckReachability: configuration.shouldCheckReachability)
//    return createFlow(connection, configuration: configuration)
//}
//
///// Used as a factory to create a `ReactorFlow` for a `SequenceType` of `T: Mappable`
//public func createFlow<T>(_ connection: Connection, configuration: FlowConfigurable = FlowConfiguration(persistenceConfiguration: .disabled)) -> ReactorFlow<T> where T: Sequence, T.Iterator.Element: Mappable {
//    
//    let parser: (Data) -> SignalProducer<T, ReactorError> = configuration.shouldPrune ? prunedParse : strictParse
//    let networkFlow: (Resource) -> SignalProducer<T, ReactorError> = { resource in connection.makeRequest(resource).map { $0.0}.flatMapLatest(parser) }
//    
//    switch configuration.persistenceConfiguration {
//    case .disabled:
//        return ReactorFlow(networkFlow: networkFlow)
//        
//    case .enabled(let persistencePath):
//        let persistenceHandler = InDiskPersistenceHandler<T>(persistenceFilePath: persistencePath)
//        let loadFromPersistence = persistenceHandler.load
//        let saveToPersistence =  persistenceHandler.save
//        
//        return ReactorFlow(networkFlow: networkFlow, loadFromPersistenceFlow: loadFromPersistence, saveToPersistenceFlow: saveToPersistence)
//    }
//}
//
///// Used as a factory to create a `ReactorFlow` for a `SequenceType` of `T: Mappable`
//public func createFlow<T>(_ baseURL: URL, configuration: FlowConfigurable = FlowConfiguration(persistenceConfiguration: .disabled)) -> ReactorFlow<T> where T: Sequence, T.Iterator.Element: Mappable {
//    
//    let connection = createConnection(baseURL, shouldCheckReachability: configuration.shouldCheckReachability)
//    return createFlow(connection, configuration: configuration)
//}
//
//private func createConnection(_ baseURL: URL, shouldCheckReachability: Bool) -> Connection {
//    
//    if shouldCheckReachability {
//        return Network(baseURL: baseURL)
//    }
//    else {
//        return Network(baseURL: baseURL, reachability: AlwaysReachable())
//    }
//}
