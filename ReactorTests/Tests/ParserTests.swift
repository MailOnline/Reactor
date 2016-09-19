//
//  ParserTests.swift
//  Reactor
//
//  Created by Rui Peres on 13/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import XCTest
import ReactiveSwift
@testable import Reactor

class ParserTests: XCTestCase {
    
    func testArticlesDecodingEncoding() {
        
        let expectation = self.expectation(description: "Expected to decode/encode multiple Articles // [T]")
        defer { self.waitForExpectations(timeout: 4.0, handler: nil) }
        
        let jsonData = dataFromFile("articles")
        
        let parserProducer: (Data) -> SignalProducer<[Article], ReactorError > = prunedParse
        
        parserProducer(jsonData).flatMapLatest { encode($0) }.flatMapLatest(parserProducer).startWithResult { articles in
            
            XCTAssertEqual(articles.value!.count, 3)
            expectation.fulfill()
        }
    }
    
    func testAuthorDecodingEncoding() {
        
        let expectation = self.expectation(description: "Expected to parse single Author // T")
        defer { self.waitForExpectations(timeout: 4.0, handler: nil) }
        
        let jsonData = dataFromFile("author")
        
        let parserProducer: (Data) -> SignalProducer<Author, ReactorError > = parse
        parserProducer(jsonData).flatMapLatest { encode($0) }.flatMapLatest(parserProducer).startWithResult { author in
            
            XCTAssertEqual(author.value!.name, "John")
            expectation.fulfill()
        }
    }

    func testMultipleBadJSON() {
        
        let expectation = self.expectation(description: "Expected to fail parsing // [T]")
        defer { self.waitForExpectations(timeout: 4.0, handler: nil) }
        
        let jsonData = dataFromFile("bad_json")
        
        let parserProducer: SignalProducer<[Article], ReactorError > = prunedParse(jsonData)
        parserProducer.startWithFailed { error in
            
            XCTAssertEqual(error, ReactorError.parser(""))
            expectation.fulfill()
        }
    }

    func testBrokenArticlesJSON() {
        
        let expectation = self.expectation(description: "Expected to fail parsing // [T]")
        defer { self.waitForExpectations(timeout: 4.0, handler: nil) }
        
        let jsonData = dataFromFile("broken_articles")
        
        let parserProducer: SignalProducer<[Article], ReactorError > = strictParse(jsonData)
        parserProducer.startWithFailed { error in
            
            XCTAssertEqual(error, ReactorError.parser(""))
            expectation.fulfill()
        }
    }

    func testSingleBadJSON() {
        
        let expectation = self.expectation(description: "Expected to fail parsing // T")
        defer { self.waitForExpectations(timeout: 4.0, handler: nil) }
        
        let jsonData = dataFromFile("bad_json")
        
        let parserProducer: SignalProducer<Author, ReactorError > = parse(jsonData)
        parserProducer.startWithFailed { error in
            
            XCTAssertEqual(error, ReactorError.parser(""))
            expectation.fulfill()
        }
    }
}
