import Foundation

final class Cache<T> where T: Hashable {
    private var cache = [Int: T]()
    private let lock = DispatchQueue(label: "cache.queue")
    
    var count: Int {
        var count: Int = 0
        lock.sync {
            count = self.cache.count
        }
        return count
    }
    
    subscript(key: Int) -> T? {
        get {
            var value: T?
            lock.sync {
                value = self.cache[key]
            }
            return value
        }
        set(newValue) {
            lock.sync {
                self.cache[key] = newValue
            }
        }
    }
    
    func removeAll() {
        lock.sync {
            self.cache.removeAll()
        }
    }
    
    func all() -> [T] {
        var all: [T] = []
        lock.sync {
            for key in self.cache.keys {
                all.append(self.cache[key]!)
            }
        }
        return all
    }
}
