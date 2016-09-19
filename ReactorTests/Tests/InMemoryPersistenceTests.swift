//
//  InMemoryPersistenceTests.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import XCTest
import ReactiveSwift
import Result
@testable import Reactor

class InMemoryPersistenceTests: XCTestCase {
    
    func testFailedLoading() {
        
        let expectation = self.expectation(description: "Expected to fail")
        defer { self.waitForExpectations(timeout: 4.0, handler: nil) }

        let cache: Cache<Article> = Cache()
        let inMemoryPersistence = InMemoryPersistenceHandler(cache: cache)

        inMemoryPersistence.load(1).startWithFailed { error in
            XCTAssertEqual(ReactorError.persistence(""), error)
            expectation.fulfill()
        }
    }
    
    func testSingleElementSaveAndLoad() {
        
        let expectation = self.expectation(description: "Expected to save and load single element")
        defer { self.waitForExpectations(timeout: 4.0, handler: nil) }
        
        let cache: Cache<Article> = Cache()
        let inMemoryPersistence = InMemoryPersistenceHandler(cache: cache)
        
        let article = Article(title: "Hello", body: "Body", authors: [], numberOfLikes: 1)
        
        inMemoryPersistence.save(article)
            .flatMapLatest { inMemoryPersistence.load($0.hashValue)}
            .startWithResult { loadedArticle in
                
                XCTAssertEqual(article, loadedArticle.value!)
                expectation.fulfill()
        }
    }
    
    func testMultipleElementsSaveAndLoad() {
        
        let expectation = self.expectation(description: "Expected to save and load multiple elements")
        defer { self.waitForExpectations(timeout: 4.0, handler: nil) }
        
        let cache: Cache<Article> = Cache()
        let inMemoryPersistence = InMemoryPersistenceHandler(cache: cache)
        
        let article1 = Article(title: "Hello1", body: "Body1", authors: [], numberOfLikes: 1)
        let article2 = Article(title: "Hello2", body: "Body2", authors: [], numberOfLikes: 2)

        let articles = [article1, article2]
        inMemoryPersistence.save(articles)
            .flatMapLatest { _ in inMemoryPersistence.load() }
            .startWithResult { articlesStored in
                
                XCTAssertEqual(articles.count, articlesStored.value!.count)
                expectation.fulfill()
        }
    }

}
