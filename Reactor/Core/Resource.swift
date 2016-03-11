//
//  Resource.swift
//  Reactor
//
//  Created by Rui Peres on 11/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import Foundation

public typealias Header = [String: String]
public typealias Query = [String: String]

// Stolen from chriseidhof/github-issues 😅
public struct Resource: Equatable, CustomStringConvertible {
    
    public let path: String
    public let method: Method
    public let headers: Header
    public let body: NSData?
    public let query: Query
    
    public init(path: String, method: Method, body: NSData? = nil, headers: Header = [:], query: Query = [:]) {
        self.path = path
        self.method = method
        self.body = body
        self.headers = headers
        self.query = query
    }
    
    public var description: String {
        return "Path:\(path)\nMethod:\(method.rawValue)\nHeaders:\(headers)"
    }
}

public func == (lhs: Resource, rhs: Resource) -> Bool {
    
    var equalBody = false
    
    switch (lhs.body, rhs.body) {
    case (nil,nil): equalBody = true
    case (nil,_?): equalBody = false
    case (_?,nil): equalBody = false
    case (let l?,let r?): equalBody = l.isEqualToData(r)
    }
    
    return (lhs.path == rhs.path && lhs.method == rhs.method && equalBody)
}

public enum Method: String {
    case OPTIONS
    case GET
    case HEAD
    case POST
    case PUT
    case PATCH
    case DELETE
    case TRACE
    case CONNECT
}

extension Resource {
    
    public func toRequest(baseURL: NSURL) -> NSURLRequest {
        
        let components = NSURLComponents(URL: baseURL, resolvingAgainstBaseURL: false)
        
        let queryString = createQueryString(query)
        if queryString != "" {
            components?.query = queryString
        }
        components?.path = path
        
        let finalURL = components?.URL ?? baseURL
        let request = NSMutableURLRequest(URL: finalURL)
        
        request.HTTPBody = body
        request.allHTTPHeaderFields = headers
        request.HTTPMethod = method.rawValue
        
        return request
    }
    
    public func addHeader(value: String, key: String) -> Resource {
        
        var headers = self.headers
        headers[key] = value
        
        return Resource(path: path, method: method, body: body, headers: headers, query: query)
    }
}

private func createQueryString(query: Query) -> String {
    
    guard query.isEmpty == false else { return "" }
    
    var queryString = ""
    
    for key in query.keys {
        queryString.appendContentsOf("\(key)=\(query[key]!)&")
    }
    
    return String(queryString.characters.dropLast())
}
