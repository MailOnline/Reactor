//
//  InDiskPersistenceTests.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import XCTest
import ReactiveCocoa
import Result
@testable import Reactor

class InDiskPersistenceTests: XCTestCase {
    
    var testFileName: String { return appendRelativePathToRoot("test") }
    
    override func tearDown() {
        removeTestFile(testFileName)
    }
    
    func testSingleElementSaveAndLoad() {
        
        let expectation = self.expectationWithDescription("Expected to save and load single element")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }
        
        let inDiskPersistence = InDiskPersistenceHandler<Article>()
        
        let article = Article(title: "Hello", body: "Body", authors: [], numberOfLikes: 1)
        let loadArticle: String -> SignalProducer<Article, Error> = inDiskPersistence.load
        
        inDiskPersistence.save(testFileName, model: article)
            .flatMapLatest { _ in loadArticle(self.testFileName) }
            .startWithNext { loadedArticle in
                
                XCTAssertEqual(article, loadedArticle)
                expectation.fulfill()
        }
    }
    
    func testMultipleElementsSaveAndLoad() {
        
        let expectation = self.expectationWithDescription("Expected to save and load multiple elements")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }
        
        let inDiskPersistence = InDiskPersistenceHandler<[Article]>()
        
        let article1 = Article(title: "Hello1", body: "Body1", authors: [], numberOfLikes: 1)
        let article2 = Article(title: "Hello2", body: "Body2", authors: [], numberOfLikes: 2)
        
        let loadArticle: String -> SignalProducer<[Article], Error> = flip(curry(inDiskPersistence.load))(prunedParse)
        
        inDiskPersistence.save(testFileName, models: [article1, article2])
            .flatMapLatest { _ in loadArticle(self.testFileName) }
            .startWithNext { articles in
                
                XCTAssertEqual(articles, [article1, article2])
                expectation.fulfill()
        }
    }
    
    func testFileExpiration() {
        
        let expectation = self.expectationWithDescription("Expected file to be expired")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }
        
        let inDiskPersistence = InDiskPersistenceHandler<Article>()
        
        let article1 = Article(title: "Hello1", body: "Body1", authors: [], numberOfLikes: 1)
                
        inDiskPersistence.save(testFileName, model: article1)
            .delay(1.5, onScheduler: QueueScheduler(name: "test"))
            .flatMapLatest { _ in
                inDiskPersistence.hasPersistenceExpired(self.testFileName, expirationTime: 1)
                    .mapError {_ in .Persistence("File not found")
                }
            }
            .startWithNext { didExpired in
                
                XCTAssertTrue(didExpired)
                expectation.fulfill()
        }
    }
}
