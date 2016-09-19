//
//  ResourceTests.swift
//  Reactor
//
//  Created by Rui Peres on 11/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import XCTest
@testable import Reactor

class ResourceTests: XCTestCase {

    func testEqualityForNilBody() {
        let resource1 = Resource(path: "/path/1", method: .GET)
        let resource2 = Resource(path: "/path/1", method: .GET)
        
        XCTAssertEqual(resource1, resource2)
    }
    
    func testEqualityForNonNilBody() {
        let resource1 = Resource(path: "/path/1", method: .GET, body: Data())
        let resource2 = Resource(path: "/path/1", method: .GET, body: Data())
        
        XCTAssertEqual(resource1, resource2)
    }
    
    func testInequalityForDifferentBody() {
        let resource1 = Resource(path: "/path/1", method: .GET)
        let resource2 = Resource(path: "/path/1", method: .GET, body: Data())
        
        XCTAssertNotEqual(resource1, resource2)
        XCTAssertNotEqual(resource2, resource1)
    }
    
    func testDescription() {
        let resource = Resource(path: "/path/", method: .GET)
        
        XCTAssertEqual(resource.description, "Path:/path/\nMethod:GET\nHeaders:[:]")
    }
    
    func testRequestConversion() {
        let body = "Hello World".data(using: String.Encoding.utf8)
        let headers = ["key" : "value"]
        let baseURL = URL(string: "http://dailyMail.api")
        
        let resource = Resource(path: "/path/1", method: .GET, body: body, headers: headers)
        let request = resource.toRequest(baseURL!)
        
        XCTAssertEqual(request.url!, baseURL?.appendingPathComponent(resource.path))
        XCTAssertEqual(request.httpMethod!, resource.method.rawValue)
        XCTAssertEqual(request.allHTTPHeaderFields!, resource.headers)
        XCTAssertEqual(request.allHTTPHeaderFields!, resource.headers)
        XCTAssertEqual(request.httpBody!, resource.body!)
    }
    
    func testAddingNewHeaderWithEmptyHeaders() {
        let resource = Resource(path: "/path/1", method: .GET)
        let newResource = resource.addHeader("value", key: "key")
        
        XCTAssertEqual(newResource.headers.keys.count, 1)
        XCTAssertEqual(newResource.headers["key"], "value")
    }
    
    func testAddingNewHeaderWithHeaders() {
        let resource = Resource(path: "/path/1", method: .GET, body: nil, headers: ["value1" : "key1"])
        let newResource = resource.addHeader("value1", key: "key1")
        
        XCTAssertEqual(newResource.headers.keys.count, 2)
        XCTAssertEqual(newResource.headers["key1"], "value1")
    }

    func testQuery() {
        let resource = Resource(path: "/path/1", method: .GET, body: nil, query: ["key1": "value1", "key2":"value2"])
        let request = resource.toRequest(URL(string: "http://api.com/")!)

        XCTAssertTrue((request.url!.absoluteString.contains("key1=value1")))
        XCTAssertTrue((request.url!.absoluteString.contains("key2=value2")))
    }
}
