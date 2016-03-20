//
//  NetworkTests.swift
//  Reactor
//
//  Created by Rui Peres on 12/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import XCTest
import Vinyl
import ReactiveCocoa
@testable import Reactor

class NetworkTests: XCTestCase {
    
    let baseURL = NSURL(string: "http://api.com/")!
    let turntable = Turntable(configuration: TurntableConfiguration(matchingStrategy: .TrackOrder))
    
    func testSuccessfulRequest() {
        
        let expectation = self.expectationWithDescription("Expected successful request")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }
        
        turntable.loadCassette("success_request_cassette")
        
        let network = Network(session: turntable, baseURL: baseURL, reachability: MutableReachability())
        let resource = Resource(path: "/test/", method: .GET)
        
        let request : SignalProducer<(NSData, NSURLResponse), Error> = network.makeRequest(resource)
        
        let assertExpectations: (NSData, NSURLResponse) -> Void  = { (data, response) in
            
            let httpResponse = response as! NSHTTPURLResponse
            
            XCTAssertFalse(isMainThread())
            XCTAssertEqual(httpResponse.statusCode, 200)
            XCTAssertEqual(data.length, 15)
        }
        
        request
            .on( failed: { _ in XCTFail() },
                completed: { expectation.fulfill() },
                next: assertExpectations)
            .start()
    }
    
    func testNetworkNotReachable() {
        
        let expectation = self.expectationWithDescription("Expected request to fail, because it's not reachable")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }
        
        turntable.loadCassette("success_request_cassette")
        
        let network = Network(session: turntable, baseURL: baseURL, reachability: MutableReachability(isReachable: false))
        let resource = Resource(path: "/test/", method: .GET)
        
        let request : SignalProducer<(NSData, NSURLResponse), Error> = network.makeRequest(resource)
        
        let assertExpectations: Error -> Void  = { error in

            XCTAssertFalse(isMainThread())
            XCTAssertEqual(error, Error.NoConnectivity)
            expectation.fulfill()
        }
        
        request
            .on( failed: assertExpectations)
            .start()
    }
    
    func testFailedRequest() {
        
        let expectation = self.expectationWithDescription("Expected request to fail")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }
        
        let error = NSError(domain: "test.domain", code: 400, userInfo: nil)
        let track = TrackFactory.createBadTrack(baseURL.URLByAppendingPathComponent("test"), statusCode: 404, error: error)
        let vinyl = Vinyl(tracks: [track])
        turntable.loadVinyl(vinyl)
        
        let network = Network(session: turntable, baseURL: baseURL, reachability: MutableReachability())
        let resource = Resource(path: "/test/", method: .GET)
        
        let request : SignalProducer<(NSData, NSURLResponse), Error> = network.makeRequest(resource)
        
        let assertExpectations: Error -> Void  = { networkError in
            
            XCTAssertFalse(isMainThread())
            XCTAssertEqual(networkError, Error.Server(error.localizedDescription))
            expectation.fulfill()
        }
        
        request
            .on( failed: assertExpectations)
            .start()
    }
    
    func testRequestModifier() {
        
        let expectation = self.expectationWithDescription("Expected request to fail")
        defer { self.waitForExpectationsWithTimeout(4.0, handler: nil) }
        
        let track = TrackFactory.createTrack(baseURL.URLByAppendingPathComponent("test"), statusCode: 302, body: NSData())
        let vinyl = Vinyl(tracks: [track])
        turntable.loadVinyl(vinyl)

        let modifier: ResponseModifier = {(data, response) in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if statusCode > 300 || statusCode < 200  {
                return SignalProducer(error: .Server("Bad status code"))
            }
            else {
                return SignalProducer(value: (data, response))
            }
        }
        
        let network = Network(session: turntable, baseURL: baseURL, reachability: MutableReachability(), responseModifier: modifier)
        let resource = Resource(path: "/test/", method: .GET)
        
        let request : SignalProducer<(NSData, NSURLResponse), Error> = network.makeRequest(resource)
        
        let assertExpectations: Error -> Void  = { networkError in
            
            XCTAssertFalse(isMainThread())
            XCTAssertEqual(networkError, Error.Server("Bad status code"))
            expectation.fulfill()
        }
        
        request
            .on( failed: assertExpectations)
            .start()
    }
}
