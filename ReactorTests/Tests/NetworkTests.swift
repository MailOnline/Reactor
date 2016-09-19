//
//  NetworkTests.swift
//  Reactor
//
//  Created by Rui Peres on 12/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import XCTest
import ReactiveSwift
@testable import Reactor

//class NetworkTests: XCTestCase {
//    
//    let baseURL = URL(string: "http://api.com/")!
//    let turntable = Turntable(configuration: TurntableConfiguration(matchingStrategy: .trackOrder))
//    
//    func testSuccessfulRequest() {
//        
//        let expectation = self.expectation(description: "Expected successful request")
//        defer { self.waitForExpectations(timeout: 4.0, handler: nil) }
//        
//        turntable.loadCassette("success_request_cassette")
//        
//        let network = Network(session: turntable, baseURL: baseURL, reachability: MutableReachability())
//        let resource = Resource(path: "/test/", method: .GET)
//        
//        let request : SignalProducer<(Data, URLResponse), Reactor.Error> = network.makeRequest(resource)
//        
//        let assertExpectations: (Data, URLResponse) -> Void  = { (data, response) in
//            
//            let httpResponse = response as! HTTPURLResponse
//            
//            XCTAssertFalse(isMainThread())
//            XCTAssertEqual(httpResponse.statusCode, 200)
//            XCTAssertEqual(data.count, 15)
//        }
//        
//        request
//            .on( failed: { _ in XCTFail() },
//                completed: { expectation.fulfill() },
//                next: assertExpectations)
//            .start()
//    }
//    
//    func testNetworkNotReachable() {
//        
//        let expectation = self.expectation(description: "Expected request to fail, because it's not reachable")
//        defer { self.waitForExpectations(timeout: 4.0, handler: nil) }
//        
//        turntable.loadCassette("success_request_cassette")
//        
//        let network = Network(session: turntable, baseURL: baseURL, reachability: MutableReachability(isReachable: false))
//        let resource = Resource(path: "/test/", method: .GET)
//        
//        let request : SignalProducer<(Data, URLResponse), Reactor.Error> = network.makeRequest(resource)
//        
//        let assertExpectations: (Reactor.Error) -> Void  = { error in
//
//            XCTAssertFalse(isMainThread())
//            XCTAssertEqual(error, Reactor.Error.noConnectivity)
//            expectation.fulfill()
//        }
//        
//        request
//            .on( failed: assertExpectations)
//            .start()
//    }
//    
//    func testFailedRequest() {
//        
//        let expectation = self.expectation(description: "Expected request to fail")
//        defer { self.waitForExpectations(timeout: 4.0, handler: nil) }
//        
//        let error = NSError(domain: "test.domain", code: 400, userInfo: nil)
//        let track = TrackFactory.createBadTrack(baseURL.appendingPathComponent("test"), statusCode: 404, error: error)
//        let vinyl = Vinyl(tracks: [track])
//        turntable.loadVinyl(vinyl)
//        
//        let network = Network(session: turntable, baseURL: baseURL, reachability: MutableReachability())
//        let resource = Resource(path: "/test/", method: .GET)
//        
//        let request : SignalProducer<(Data, URLResponse), Reactor.Error> = network.makeRequest(resource)
//        
//        let assertExpectations: (Reactor.Error) -> Void  = { networkError in
//            
//            XCTAssertFalse(isMainThread())
//            XCTAssertEqual(networkError, Reactor.Error.server(error.localizedDescription))
//            expectation.fulfill()
//        }
//        
//        request
//            .on( failed: assertExpectations)
//            .start()
//    }
//    
//    func testRequestModifier() {
//        
//        let expectation = self.expectation(description: "Expected request to fail")
//        defer { self.waitForExpectations(timeout: 4.0, handler: nil) }
//        
//        let track = TrackFactory.createTrack(baseURL.appendingPathComponent("test"), statusCode: 302, body: Data())
//        let vinyl = Vinyl(tracks: [track])
//        turntable.loadVinyl(vinyl)
//
//        let modifier: ResponseModifier = {(data, response) in
//            
//            let httpResponse = response as! HTTPURLResponse
//            let statusCode = httpResponse.statusCode
//            
//            if statusCode > 300 || statusCode < 200  {
//                return SignalProducer(error: .server("Bad status code"))
//            }
//            else {
//                return SignalProducer(value: (data, response))
//            }
//        }
//        
//        let network = Network(session: turntable, baseURL: baseURL, reachability: MutableReachability(), responseModifier: modifier)
//        let resource = Resource(path: "/test/", method: .GET)
//        
//        let request : SignalProducer<(Data, URLResponse), Reactor.Error> = network.makeRequest(resource)
//        
//        let assertExpectations: (Reactor.Error) -> Void  = { networkError in
//            
//            XCTAssertFalse(isMainThread())
//            XCTAssertEqual(networkError, Reactor.Error.server("Bad status code"))
//            expectation.fulfill()
//        }
//        
//        request
//            .on( failed: assertExpectations)
//            .start()
//    }
//}
