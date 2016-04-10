//
//  Resource.swift
//  Reactor
//
//  Created by Rui Peres on 11/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import Foundation

public typealias Headers = [String: String]
public typealias Query = [String: String]

/// Stolen from chriseidhof/github-issues 😅
/// Used to represent a request. The baseURL should be provided somewhere else
public struct Resource: Equatable, CustomStringConvertible {
    
    public let path: String
    public let method: Method
    public let headers: Headers
    public let body: NSData?
    public let query: Query
    
    public init(path: String, method: Method, body: NSData? = nil, headers: Headers = [:], query: Query = [:]) {
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
    
    /// Used to transform a Resource into a NSURLRequest
    public func toRequest(baseURL: NSURL) -> NSURLRequest {
        
        let components = NSURLComponents(URL: baseURL, resolvingAgainstBaseURL: false)
        
        components?.queryItems = createQueryItems(query)
        components?.path = path
        
        let finalURL = components?.URL ?? baseURL
        let request = NSMutableURLRequest(URL: finalURL)
        
        request.HTTPBody = body
        request.allHTTPHeaderFields = headers
        request.HTTPMethod = method.rawValue
        
        return request
    }
    
    /// Creates a new Resource by adding the new header.
    public func addHeader(value: String, key: String) -> Resource {
        
        var headers = self.headers
        headers[key] = value
        
        return Resource(path: path, method: method, body: body, headers: headers, query: query)
    }
    
    private func createQueryItems(query: Query) -> [NSURLQueryItem]? {
        
        guard query.isEmpty == false else { return nil }
        
        return query.map { (key, value) in
            return NSURLQueryItem(name: key, value: value)
        }
    }
}