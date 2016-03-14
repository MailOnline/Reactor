//
//  CacheTests.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import XCTest
@testable import Reactor

class CacheTests: XCTestCase {

    func testSetGet() {
        
        let cache = Cache<Article>()
        let article = Article(title: "Hello", body: "Body", authors: [], numberOfLikes: 1)
        
        cache[article.hashValue] = article
        
        XCTAssertEqual(cache[article.hashValue], article)
    }
    
    func testRemoveAll() {
        
        let cache = Cache<Article>()
        let article = Article(title: "Hello", body: "Body", authors: [], numberOfLikes: 1)
        
        cache[article.hashValue] = article
        cache.removeAll()
        
        XCTAssertEqual(cache.count, 0)
    }
    
    func testAll() {
        
        let cache = Cache<Article>()
        let article = Article(title: "Hello", body: "Body", authors: [], numberOfLikes: 1)
        
        cache[article.hashValue] = article
        let all = cache.all()
        
        XCTAssertEqual(all, [article])
    }
}
