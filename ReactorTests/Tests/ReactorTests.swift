//
//  ReactorTests.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import XCTest
import ReactiveCocoa
import Result
import Vinyl
@testable import Reactor

class ReactorTests: XCTestCase {
    
    var testFileName: String { return appendRelativePathToRoot("test") }
    let baseURL = NSURL(string: "http://api.com/")!
    let turntable = Turntable(configuration: TurntableConfiguration(matchingStrategy: .TrackOrder))
    
    override func tearDown() {
        removeTestFile(testFileName)
    }
    
    func testSuccessfullNetworkCall() {
        
        let expectation = self.expectationWithDescription("Expected to persist articles after successful request")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }
        
        turntable.loadCassette("articles_cassette")
        
        let resource = Resource(path: "/test/", method: .GET)
        let network = Network(session: turntable, baseURL: baseURL, reachability: MutableReachability())
        let inDiskPersistence = InDiskPersistenceHandler<[Article]>(persistenceFilePath: testFileName)
        let loadArticles: Void -> SignalProducer<[Article], Error> = inDiskPersistence.load
        
        let flow = createMockedFlow(network)
        let reactor = Reactor(flow: flow)
        
        reactor.fetch(resource).flatMapLatest { _ in loadArticles() }.startWithNext { articles in
            
            XCTAssertFalse(isMainThread())
            XCTAssertEqual(articles.count, 3)
            expectation.fulfill()
        }
    }
    
    func testShouldGetPersistedValues() {
        
        let expectation = self.expectationWithDescription("Expected to fetch from persistence")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }
        
        let resource = Resource(path: "/test/", method: .GET)
        let network = NetworkLayerIsCalled(connectionCalled: { fatalError("Shouldn't be called")})
        let inDiskPersistence = InDiskPersistenceHandler<[Article]>(persistenceFilePath: testFileName)
        let flow = createMockedFlow(network)
        
        let article1 = Article(title: "Hello1", body: "Body1", authors: [], numberOfLikes: 1)
        let article2 = Article(title: "Hello2", body: "Body2", authors: [], numberOfLikes: 2)
        
        let reactor = Reactor(flow: flow)
        
        inDiskPersistence.save([article1, article2]).startWithNext {_ in
            
            reactor.fetch(resource).startWithNext { articles in
                
                XCTAssertFalse(isMainThread())
                XCTAssertEqual(articles, [article1, article2])
                expectation.fulfill()
            }
        }
    }
    
    func testWithEmptyPathPersistenceIsNotReached() {
        
        let expectation = self.expectationWithDescription("Expected to not persist anything")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }
        
        let resource = Resource(path: "/test/", method: .GET)
        let network = NetworkLayerIsCalled(connectionCalled: {
            
            XCTAssertFalse(isMainThread())
            expectation.fulfill()
        })
        
        let networkFlow: Resource -> SignalProducer<[Article], Error> = { resource in
            network.makeRequest(resource).map { $0.0} .flatMapLatest(prunedParse)
        }
        
        let flow = ReactorFlow(networkFlow: networkFlow)
        let reactor = Reactor(flow: flow)
        
        reactor.fetch(resource).start()
    }
    
    func testShouldNotPersistIfSaveToPersistenceFlowIsMissing() {
        
        let expectation = self.expectationWithDescription("Expected to fail, if no saveToPersistenceFlow is provided")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }
        
        turntable.loadCassette("author_cassette")
        
        let resource = Resource(path: "/test/", method: .GET)
        let network = Network(session: turntable, baseURL: baseURL, reachability: MutableReachability())
        let inDiskPersistence = InDiskPersistenceHandler<Author>(persistenceFilePath: testFileName)
        
        let loadArticles: Void -> SignalProducer<Author, Error> = inDiskPersistence.load
        let networkFlow: Resource -> SignalProducer<Author, Error> = { resource in
            network.makeRequest(resource).map { $0.0} .flatMapLatest(parse)
        }
        
        let flow = ReactorFlow(networkFlow: networkFlow, loadFromPersistenceFlow: loadArticles)        
        let reactor = Reactor(flow: flow)
        
        reactor.fetch(resource).flatMapLatest { _ in loadArticles()}.startWithFailed { error in
            
            XCTAssertFalse(isMainThread())
            XCTAssertEqual(error, Error.Persistence(""))
            expectation.fulfill()
        }
    }
    
    func testShouldNotFailWhenSaveToPersistenceFails() {
        
        let expectation = self.expectationWithDescription("Expected to not fail, even if saveToPersistenceFlowfails")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }
        
        turntable.loadCassette("author_cassette")
        
        let resource = Resource(path: "/test/", method: .GET)
        let network = Network(session: turntable, baseURL: baseURL, reachability: MutableReachability())
        let inDiskPersistence = InDiskPersistenceHandler<Author>(persistenceFilePath: testFileName)
        
        let loadArticles: Void -> SignalProducer<Author, Error> = inDiskPersistence.load
        let saveArticles: Author -> SignalProducer<Author, Error> = { _ in SignalProducer(error: .Persistence("Save failed")) }
        
        let networkFlow: Resource -> SignalProducer<Author, Error> = { resource in
            network.makeRequest(resource).map { $0.0} .flatMapLatest(parse)
        }
        
        var configuration = CoreConfiguration()
        configuration.shouldFailWhenSaveToPersistenceFails = false
        
        let flow = ReactorFlow(networkFlow: networkFlow, loadFromPersistenceFlow: loadArticles, saveToPersistenceFlow: saveArticles)
        let reactor = Reactor(flow: flow, configuration: configuration)
        
        reactor.fetchFromNetwork(resource).startWithNext { author in
            
            XCTAssertFalse(isMainThread())
            expectation.fulfill()
        }
    }
    
    func testShouldNotFailWhenSaveToPersistenceFailsButItsASideEffect() {
        
        let expectation = self.expectationWithDescription("Expected to not fail, even if saveToPersistenceFlowfails")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }
        
        turntable.loadCassette("author_cassette")
        
        let resource = Resource(path: "/test/", method: .GET)
        let network = Network(session: turntable, baseURL: baseURL, reachability: MutableReachability())
        let inDiskPersistence = InDiskPersistenceHandler<Author>(persistenceFilePath: testFileName)
        
        let loadArticles: Void -> SignalProducer<Author, Error> = inDiskPersistence.load
        let saveArticles: Author -> SignalProducer<Author, Error> = { _ in SignalProducer(error: .Persistence("Save failed")) }
        
        let networkFlow: Resource -> SignalProducer<Author, Error> = { resource in
            network.makeRequest(resource).map { $0.0} .flatMapLatest(parse)
        }
        
        var configuration = CoreConfiguration()
        configuration.shouldFailWhenSaveToPersistenceFails = true
        configuration.shouldWaitForSaveToPersistence = false

        let flow = ReactorFlow(networkFlow: networkFlow, loadFromPersistenceFlow: loadArticles, saveToPersistenceFlow: saveArticles)
        let reactor = Reactor(flow: flow, configuration: configuration)
        
        reactor.fetchFromNetwork(resource).startWithNext { author in
            
            XCTAssertFalse(isMainThread())
            expectation.fulfill()
        }
    }
    
    func testShouldNotPassWhenItIsStrickAndThereAreBadObjects() {
        
        let expectation = self.expectationWithDescription("Expected to fail, if no saveToPersistenceFlow is provided")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }
        
        turntable.loadCassette("broken_articles_cassette")
        
        let resource = Resource(path: "/test/", method: .GET)
        let network = Network(session: turntable, baseURL: baseURL, reachability: MutableReachability())

        let flow = createMockedFlow(network, parser: strictParse)
        let reactor = Reactor(flow: flow)
        
        reactor.fetch(resource).flatMapLatest { _ in flow.loadFromPersistenceFlow() }.startWithFailed { error in
            
            XCTAssertFalse(isMainThread())
            XCTAssertEqual(error, Error.Parser(""))
            expectation.fulfill()
        }
    }
    
    func testPersistenceExistsForSequence() {
        
        let expectation = self.expectationWithDescription("Expected to persistence to exist")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }

        turntable.loadCassette("articles_cassette")
        
        let resource = Resource(path: "/test/", method: .GET)
        let network = Network(session: turntable, baseURL: baseURL, reachability: MutableReachability())
        
        let configuration = FlowConfiguration(persistenceConfiguration: .Enabled(withPath: testFileName))
        let flow: ReactorFlow<[Article]> = createFlow(network, configuration: configuration)
        let reactor = Reactor(flow: flow)

        reactor.fetch(resource).flatMapLatest { _ in flow.loadFromPersistenceFlow() }.startWithNext{ articles in
            
            XCTAssertFalse(isMainThread())
            expectation.fulfill()
        }
    }
    
    func testPersistenceDoesntExistForSequence() {
        
        let expectation = self.expectationWithDescription("Expected to persistence to not exist")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }
        
        turntable.loadCassette("articles_cassette")
        
        let resource = Resource(path: "/test/", method: .GET)
        let network = Network(session: turntable, baseURL: baseURL, reachability: MutableReachability())
        
        let configuration = FlowConfiguration(persistenceConfiguration: .Disabled)
        let flow: ReactorFlow<[Article]> = createFlow(network, configuration: configuration)
        let reactor = Reactor(flow: flow)
        
        reactor.fetch(resource).flatMapLatest { _ in flow.loadFromPersistenceFlow() }.startWithFailed { error in
            
            XCTAssertFalse(isMainThread())
            expectation.fulfill()
        }
    }
    
    func testPersistenceExistsForSingleModel() {
        
        let expectation = self.expectationWithDescription("Expected to persistence to exist")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }
        
        turntable.loadCassette("author_cassette")
        
        let resource = Resource(path: "/test/", method: .GET)
        let network = Network(session: turntable, baseURL: baseURL, reachability: MutableReachability())
        
        let configuration = FlowConfiguration(persistenceConfiguration: .Enabled(withPath: testFileName))
        let flow: ReactorFlow<Author> = createFlow(network, configuration: configuration)
        let reactor = Reactor(flow: flow)
        
        reactor.fetch(resource).flatMapLatest { _ in flow.loadFromPersistenceFlow() }.startWithNext{ author in
            
            XCTAssertFalse(isMainThread())
            expectation.fulfill()
        }
    }
    
    func testPersistenceDoesntExistForSingleModel() {
        
        let expectation = self.expectationWithDescription("Expected to persistence to not exist")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }
        
        turntable.loadCassette("author_cassette")
        
        let resource = Resource(path: "/test/", method: .GET)
        let network = Network(session: turntable, baseURL: baseURL, reachability: MutableReachability())
        
        let configuration = FlowConfiguration(persistenceConfiguration: .Disabled)
        let flow: ReactorFlow<Author> = createFlow(network, configuration: configuration)
        let reactor = Reactor(flow: flow)
        
        reactor.fetch(resource).flatMapLatest { _ in flow.loadFromPersistenceFlow() }.startWithFailed { error in
            
            XCTAssertFalse(isMainThread())
            expectation.fulfill()
        }
    }
    
    private func createMockedFlow(connection: Connection, parser: NSData -> SignalProducer<[Article], Error> = prunedParse) -> ReactorFlow<[Article]> {
        
        let inDiskPersistence = InDiskPersistenceHandler<[Article]>(persistenceFilePath: testFileName)
        let loadArticles: Void -> SignalProducer<[Article], Error> = inDiskPersistence.load
        let saveArticles: [Article] -> SignalProducer<[Article], Error> = inDiskPersistence.save
        
        let networkFlow: Resource -> SignalProducer<[Article], Error> = { resource in
            connection.makeRequest(resource).map { $0.0} .flatMapLatest(parser)
        }
        
        let flow = ReactorFlow(networkFlow: networkFlow, loadFromPersistenceFlow: loadArticles, saveToPersistenceFlow: saveArticles)
        return flow
    }
}
