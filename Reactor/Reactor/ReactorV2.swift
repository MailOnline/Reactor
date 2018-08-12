import Foundation
import enum Result.NoError
import ReactiveSwift

public final class ReactorV2<T> {
    private let connectable: Connectable
    private let flows: Atomic<ReactorV2.Flows> = Atomic(ReactorV2.Flows())

    public init(connectable: Connectable) {
        self.connectable = connectable
    }
}

extension ReactorV2 where T == Data {
    func fetch(with request: URLRequest) -> ReactorV2<T> {
        return self
    }
}

extension ReactorV2 {
    typealias NetworkFlow = (URLRequest) -> SignalProducer<Data, ReactorError>
    typealias ParsingFlow = (Data) -> SignalProducer<T, ReactorError>
    typealias LoadFlow = (String) -> SignalProducer<T, ReactorError>
    typealias SaveFlow = (String) -> (T) -> SignalProducer<T, ReactorError>

    struct Flows {
        let networkFlow: NetworkFlow
        let parsingFlow: ParsingFlow
        let loadFlow: LoadFlow
        let saveFlow: SaveFlow

        init(networkFlow: @escaping NetworkFlow = { _ in SignalProducer.empty },
             parsingFlow: @escaping ParsingFlow = { _ in SignalProducer.empty },
             loadFlow: @escaping LoadFlow = { _ in SignalProducer.empty },
             saveFlow: @escaping SaveFlow = { _ in { _ in SignalProducer.empty } }) {
            self.networkFlow = networkFlow
            self.parsingFlow = parsingFlow
            self.loadFlow = loadFlow
            self.saveFlow = saveFlow
        }
    }
}


/*


 let reactor = Reactor<FooBar>.fetch(from:)



 */
