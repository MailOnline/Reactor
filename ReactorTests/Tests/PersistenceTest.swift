//
//  PersistenceTest.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import XCTest
import ReactiveSwift
import Result
@testable import Reactor

class PersistenceTest: XCTestCase {
    
    var testFileName: String { return appendRelativePathToRoot("test") }
    
    override func tearDown() {
        removeTestFile(testFileName)
    }
    
    func testWritingPersistenceSuccessfully() {
        
        let expectation = self.expectation(description: "Expected data to be persisted with success")
        defer { self.waitForExpectations(timeout: 4.0, handler: nil) }
        
        let writingSignal = writeToFile(testFileName, data: dataFromFile("articles"))
            .on(
            completed: {
                expectation.fulfill()
            })
        
        writingSignal.start()
    }
    
    func testReadingPersistenceSuccess() {
        let expectation = self.expectation(description: "Expected data to be read with succcess")
        defer { self.waitForExpectations(timeout: 4.0, handler: nil) }
        
        let data = dataFromFile("articles")
        
        let readingSignal = readFileData(testFileName)
            .on(
                value: { x in
                    XCTAssertEqual(x.count, data.count)
                    removeTestFile(self.testFileName)
                },
                completed: {
                    expectation.fulfill()})
        
        let writingSignal = writeToFile(testFileName, data: data) . on(completed: {
            readingSignal.start()
        })
        
        writingSignal.start()
    }
    
    func testReadingPersistenceFailure() {
        let expectation = self.expectation(description: "Expected to fail")
        defer { self.waitForExpectations(timeout: 4.0, handler: nil) }

        let readingSignal = readFileData(testFileName).on(failed: {error in expectation.fulfill() })
        
        readingSignal.start()
    }
    
    func testFileDoesNotExist() {
        
        let expectation = self.expectation(description: "Expected to not find any file")
        defer { self.waitForExpectations(timeout: 4.0, handler: nil) }
        
        doesFileExists(testFileName)
            .on(
                value: { doesFileExists in
                    XCTAssertEqual(doesFileExists, false)
                },
                completed: {
                    expectation.fulfill()
            })
            .start()
    }
    
    func testFileDoesExist() {
        
        let expectation = self.expectation(description: "Expected to find file")
        defer { self.waitForExpectations(timeout: 4.0, handler: nil) }
        
        let doesFileExitsSignal = doesFileExists(testFileName).on(
            value: { doesFileExists in
                XCTAssertEqual(doesFileExists, true)
            },
            completed: {
                expectation.fulfill() })

        writeToFile(testFileName, data: dataFromFile("articles")).on (completed: {
            doesFileExitsSignal.start()
        }).start()
    }
    
    func testShouldFailWithBadPath() {
        let expectation = self.expectation(description: "Expected to fail with bad path")
        defer { self.waitForExpectations(timeout: 4.0, handler: nil) }
        
        let fullPath = testFileName
        
        try! FileManager.default.setAttributes([:], ofItemAtPath: testFileName)
        
        fileCreationDate(fullPath)
            .on(
                value: { _ in
                    XCTFail()
                },
                failed: { _  in
                    expectation.fulfill()
            })
            .start()
    }
}
