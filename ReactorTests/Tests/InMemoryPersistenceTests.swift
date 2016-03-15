//
//  InMemoryPersistenceTests.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import XCTest
import ReactiveCocoa
import Result
@testable import Reactor

class InMemoryPersistenceTests: XCTestCase {
    
    func testSingleElementSaveAndLoad() {
        
        let expectation = self.expectationWithDescription("Expected to save and load single element")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }
        
        let cache: Cache<Article> = Cache()
        let inMemoryPersistence = InMemoryPersistenceHandler(cache: cache)
        
        let article = Article(title: "Hello", body: "Body", authors: [], numberOfLikes: 1)
        
        inMemoryPersistence.save(article)
            .flatMapLatest { inMemoryPersistence.load($0.hashValue)}
            .startWithNext { loadedArticle in
                
                XCTAssertEqual(article, loadedArticle)
                expectation.fulfill()
        }
    }
    
    func testMultipleElementsSaveAndLoad() {
        
        let expectation = self.expectationWithDescription("Expected to save and load multiple elements")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }
        
        let cache: Cache<Article> = Cache()
        let inMemoryPersistence = InMemoryPersistenceHandler(cache: cache)
        
        let article1 = Article(title: "Hello1", body: "Body1", authors: [], numberOfLikes: 1)
        let article2 = Article(title: "Hello2", body: "Body2", authors: [], numberOfLikes: 2)

        let articles = [article1, article2]
        inMemoryPersistence.save(articles)
            .flatMapLatest { _ in inMemoryPersistence.load() }
            .startWithNext { articlesStored in
                
                XCTAssertEqual(articles.count, articlesStored.count)
                expectation.fulfill()
        }
    }

}