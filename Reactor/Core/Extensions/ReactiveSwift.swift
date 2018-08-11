import ReactiveSwift

extension SignalProducer {
    
    /// Used to yield the same input. This is useful in scenarios where there is a possibility of having a transformation (via a flatMap)
    /// but by default, nothing will happen. It makes it much more elegant, than checking for a nil transformation and apply it conditionally
    public static var identity: ((Value) -> SignalProducer<Value, Error>) { return { SignalProducer(value: $0) } }

    /// More explicit call to `on(next: next)`.
    public func injectSideEffect(_ next: @escaping (Value) -> ()) -> SignalProducer<Value, Error> {
        return self.producer.on(value: next)
    }
    
    /// Convenience method to `flatMap(.latest , transform: transform)`
    public func flatMapLatest<Inner: SignalProducerConvertible>(_ transform: @escaping (Value) -> Inner) -> SignalProducer<Inner.Value, Error> where Inner.Error == Error {
        return self.flatMap(.latest, transform)
    }
}
