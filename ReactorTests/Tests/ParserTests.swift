//
//  ParserTests.swift
//  Reactor
//
//  Created by Rui Peres on 13/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import XCTest
import ReactiveCocoa
@testable import Reactor

class ParserTests: XCTestCase {
    

    func testArticlesDecodingEncoding() {
        
        let expectation = self.expectationWithDescription("Expected to decode/encode multiple Articles // [T]")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }
        
        let jsonData = dataFromFile("articles")
        
        let parserProducer: NSData -> SignalProducer<[Article], Error > = parse
        parserProducer(jsonData).flatMapLatest { encode($0) }.flatMapLatest(parserProducer).startWithNext { articles in
            
            XCTAssertEqual(articles.count, 3)
            expectation.fulfill()
        }
    }
    
    func testAuthorDecodingEncoding() {
        
        let expectation = self.expectationWithDescription("Expected to parse single Author // T")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }
        
        let jsonData = dataFromFile("author")
        
        let parserProducer: NSData -> SignalProducer<Author, Error > = parse
        parserProducer(jsonData).flatMapLatest { encode($0) }.flatMapLatest(parserProducer).startWithNext { author in
            
            XCTAssertEqual(author.name, "John")
            expectation.fulfill()
        }
    }
    
    func testMultipleBadJSON() {
        
        let expectation = self.expectationWithDescription("Expected to fail parsing // [T]")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }
        
        let jsonData = dataFromFile("bad_json")
        
        let parserProducer: SignalProducer<[Article], Error > = parse(jsonData)
        parserProducer.startWithFailed { error in
            
            XCTAssertEqual(error, Error.Parser)
            expectation.fulfill()
        }
    }
    
    func testSingleBadJSON() {
        
        let expectation = self.expectationWithDescription("Expected to fail parsing // T")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }
        
        let jsonData = dataFromFile("bad_json")
        
        let parserProducer: SignalProducer<Author, Error > = parse(jsonData)
        parserProducer.startWithFailed { error in
            
            XCTAssertEqual(error, Error.Parser)
            expectation.fulfill()
        }
    }
}
