import Foundation

public typealias Headers = [String: String]
public typealias Query = [String: String]

/// Stolen from chriseidhof/github-issues 😅
/// Used to represent a request. The baseURL should be provided somewhere else
public struct Resource: Equatable, CustomStringConvertible {
    
    public let path: String
    public let method: Method
    public let headers: Headers
    public let body: Data?
    public let query: Query
    
    public init(path: String, method: Method, body: Data? = nil, headers: Headers = [:], query: Query = [:]) {
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
    case (let l?,let r?): equalBody = l == r
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
    public func toRequest(_ baseURL: URL) -> URLRequest {
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        
        components?.queryItems = createQueryItems(query)
        components?.path = path
        
        let finalURL = components?.url ?? baseURL
        let request = NSMutableURLRequest(url: finalURL)
        
        request.httpBody = body
        request.allHTTPHeaderFields = headers
        request.httpMethod = method.rawValue
        
        return request as URLRequest
    }
    
    /// Creates a new Resource by adding the new header.
    public func addHeader(_ value: String, key: String) -> Resource {
        
        var headers = self.headers
        headers[key] = value
        
        return Resource(path: path, method: method, body: body, headers: headers, query: query)
    }
    
    private func createQueryItems(_ query: Query) -> [URLQueryItem]? {
        
        guard query.isEmpty == false else { return nil }
        
        return query.map { (key, value) in
            return URLQueryItem(name: key, value: value)
        }
    }
}
