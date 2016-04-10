//
//  Cache.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import Foundation

final class Cache<T where T: Hashable> {
    
    private var cache = [Int: T]()
    private let lock = dispatch_queue_create("cache.queue", DISPATCH_QUEUE_SERIAL)
    
    var count: Int { return cache.count }
    
    subscript(key: Int) -> T? {
        
        get {
            var value: T?
            dispatch_sync(lock) {
                value = self.cache[key]
            }
            return value
        }
        
        set(newValue) {
            dispatch_sync(lock) {
                self.cache[key] = newValue
            }
        }
    }
    
    func removeAll() {
        dispatch_sync(lock) {
            self.cache.removeAll()
        }
    }
    
    func all() -> [T] {
        
        var all: [T] = []
        
        dispatch_sync(lock) {
            for key in self.cache.keys {
                all.append(self.cache[key]!)
            }
        }
        return all
    }
}