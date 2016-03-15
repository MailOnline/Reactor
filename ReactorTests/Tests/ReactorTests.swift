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
            
                XCTAssertEqual(articles, [article1, article2])
                expectation.fulfill()
            }
        }
    }
    
    private func createMockedFlow(connection: Connection) -> ReactorFlow<[Article]> {
    
        let inDiskPersistence = InDiskPersistenceHandler<[Article]>(persistenceFilePath: testFileName)
        let loadArticles: Void -> SignalProducer<[Article], Error> = inDiskPersistence.load
        let saveArticles: [Article] -> SignalProducer<[Article], Error> = inDiskPersistence.save
        
        let networkRequest: Resource -> SignalProducer<[Article], Error> = { resource in
            connection.makeRequest(resource).map { $0.0} .flatMapLatest(parse)
        }
        
        let flow = ReactorFlow(networkRequest: networkRequest, loadFromPersistence: loadArticles, saveToPersistence: saveArticles)
        return flow
    }
}
