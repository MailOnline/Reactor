//
//  PersistenceTest.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import XCTest
import ReactiveCocoa
import Result
@testable import Reactor

class PersistenceTest: XCTestCase {
    
    var testFileName: String { return appendRelativePathToRoot("test") }
    
    override func tearDown() {
        removeTestFile(testFileName)
    }
    
    func testWritingPersistenceSuccessfully() {
        
        let expectation = self.expectationWithDescription("Expected data to be persisted with success")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }
        
        let writingSignal = writeToFile(testFileName, data: dataFromFile("articles"))
            .on(
            completed: {
                expectation.fulfill()
            })
        
        writingSignal.start()
    }
    
    func testReadingPersistenceSuccess() {
        let expectation = self.expectationWithDescription("Expected data to be read with succcess")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }
        
        let data = dataFromFile("articles")
        
        let readingSignal = readFileData(testFileName)
            .on(
            completed: {
                expectation.fulfill()},
            next: { x in
                XCTAssertEqual(x.length, data.length)
                removeTestFile(self.testFileName)
        })
        
        let writingSignal = writeToFile(testFileName, data: data) . on(completed: {
            readingSignal.start()
        })
        
        writingSignal.start()
    }
    
    func testReadingPersistenceFailure() {
        let expectation = self.expectationWithDescription("Expected to fail")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }
        
        let readingSignal = readFileData(testFileName).on(failed: {error in expectation.fulfill() })
        
        readingSignal.start()
    }
    
    func testFileDoesNotExist() {
        
        let expectation = self.expectationWithDescription("Expected to not find any file")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }
        
        doesFileExists(testFileName)
            .on(
                completed: {
                    expectation.fulfill()
                },
                next: { doesFileExists in
                    XCTAssertEqual(doesFileExists, false)
            })
            .start()
    }
    
    func testFileDoesExist() {
        
        let expectation = self.expectationWithDescription("Expected to find file")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }
        
        let doesFileExitsSignal = doesFileExists(testFileName).on(
            completed: {
                expectation.fulfill() },
            next: { doesFileExists in
                XCTAssertEqual(doesFileExists, true)
        })
        
        writeToFile(testFileName, data: dataFromFile("articles")).on (completed: {
            doesFileExitsSignal.start()
        }).start()
    }
    
    func testShouldFailWithBadPath() {
        let expectation = self.expectationWithDescription("Expected to fail with bad path")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }
        
        let fullPath = testFileName
        
        try! NSFileManager.defaultManager().setAttributes([:], ofItemAtPath: testFileName)
        
        fileCreationDate(fullPath)
            .on(
                started: { _ in
                    expectation.fulfill()
                },
                next: { _  in
                    XCTFail()
            })
            .start()
    }
}
