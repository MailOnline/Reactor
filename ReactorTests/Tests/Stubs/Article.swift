//
//  Article.swift
//  Reactor
//
//  Created by Rui Peres on 13/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import Foundation
import Result
@testable import Reactor

private func arrayToJSON<T: Mappable>(input: [T]) -> AnyObject {
    
    var a: [AnyObject] = []
    
    for i in input {
        
        let o = i.mapToJSON()
        a.append(o)
        
    }
    
    return a
}

struct Author {
    let name: String
}

struct Article {
    let title: String
    let body: String
    let authors: [Author]
    let numberOfLikes: Int
}

extension Article: Hashable {
    
    var hashValue: Int {
        return title.hashValue
    }
}

extension Article: Equatable {}

func == (lhs: Article, rhs: Article) -> Bool {
    return lhs.title == rhs.title && lhs.body == rhs.body && lhs.numberOfLikes == rhs.numberOfLikes
}

extension Author: Mappable {
    
    static func mapToModel(object: AnyObject) -> Result<Author, MappedError> {
        
        guard
            let dictionary = object as? [String: AnyObject],
            let name = dictionary["name"] as? String
            else { return Result(error: MappedError.Custom("Invalid dictionary @ \(Author.self)\n \(object)"))}
        
        let author = Author(name: name)
        
        return Result(value: author)
    }
    
    func mapToJSON() -> AnyObject {
        
        return ["name": self.name]
    }
}

extension Article: Mappable {
    
    static func mapToModel(object: AnyObject) -> Result<Article, MappedError> {
        
        guard
            let dictionary = object as? [String: AnyObject],
            let title = dictionary["title"] as? String,
            let body = dictionary["body"] as? String,
            let authors: [Author] = arrayFromJSON(dictionary, key: "authors"),
            let numberOfLikes = dictionary["numberOfLikes"] as? Int
            else { return Result(error: MappedError.Custom("Invalid dictionary @ \(Article.self)\n \(object)"))}
        
        let video = Article(title: title, body: body, authors: authors, numberOfLikes: numberOfLikes)
        
        return Result(value: video)
    }

    func mapToJSON() -> AnyObject {
        
        var d: [String:AnyObject] = [:]
        
        d["title"] = title
        d["body"] = body
        d["authors"] = arrayToJSON(authors)
        d["numberOfLikes"] = numberOfLikes
        
        return d
    }
}
