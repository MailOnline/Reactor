//
//  InDiskPersistenceTests.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import XCTest
import ReactiveSwift
import Result
@testable import Reactor

class InDiskPersistenceTests: XCTestCase {
    
    var testFileName: String { return appendRelativePathToRoot("test") }
    
    override func tearDown() {
        removeTestFile(testFileName)
    }
    
    func testSingleElementSaveAndLoad() {
        
        let expectation = self.expectation(description: "Expected to save and load single element")
        defer { self.waitForExpectations(timeout: 4.0, handler: nil) }
        
        let inDiskPersistence = InDiskPersistenceHandler<Article>(persistenceFilePath: testFileName)
        
        let article = Article(title: "Hello", body: "Body", authors: [], numberOfLikes: 1)
        let loadArticle: (Void) -> SignalProducer<Article, ReactorError> = inDiskPersistence.load
        
        inDiskPersistence.save(article)
            .flatMapLatest { _ in loadArticle() }
            .startWithResult { loadedArticle in
                
                XCTAssertEqual(article, loadedArticle.value!)
                expectation.fulfill()
        }
    }
    
    func testMultipleElementsSaveAndLoad() {
        
        let expectation = self.expectation(description: "Expected to save and load multiple elements")
        defer { self.waitForExpectations(timeout: 4.0, handler: nil) }
        
        let inDiskPersistence = InDiskPersistenceHandler<[Article]>(persistenceFilePath: testFileName)
        
        let article1 = Article(title: "Hello1", body: "Body1", authors: [], numberOfLikes: 1)
        let article2 = Article(title: "Hello2", body: "Body2", authors: [], numberOfLikes: 2)
        
        let loadArticle: (Void) -> SignalProducer<[Article], ReactorError> = inDiskPersistence.load
        
        inDiskPersistence.save([article1, article2])
            .flatMapLatest { _ in loadArticle() }
            .startWithResult { articles in
                
                XCTAssertEqual(articles.value!, [article1, article2])
                expectation.fulfill()
        }
    }
    
    func testFileExpiration() {
        
        let expectation = self.expectation(description: "Expected file to be expired")
        defer { self.waitForExpectations(timeout: 4.0, handler: nil) }
        
        let inDiskPersistence = InDiskPersistenceHandler<Article>(persistenceFilePath: testFileName, expirationTime: 1)
        
        let article1 = Article(title: "Hello1", body: "Body1", authors: [], numberOfLikes: 1)
                
        inDiskPersistence.save(article1)
            .delay(1.5, on: QueueScheduler(name: "test"))
            .flatMapLatest { _ in
                inDiskPersistence.hasPersistenceExpired()
                    .mapError {_ in .persistence("File not found")
                }
            }
            .startWithResult { didExpired in
                
                XCTAssertTrue(didExpired.value!)
                expectation.fulfill()
        }
    }
}
