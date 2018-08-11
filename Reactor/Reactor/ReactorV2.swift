import Foundation
import enum Result.NoError
import ReactiveSwift

final class ReactorV2<T> {
    private let session: URLSession

    fileprivate let tasks: Property<[Task]>
    fileprivate let tasksObserver: Signal<[Task], NoError>.Observer

    init(session: URLSession = .shared) {
        self.session = session

        let (tasks, tasksObserver) = Signal<[Task], NoError>.pipe()
        self.tasks = Property.init(initial: [], then: tasks)
        self.tasksObserver = tasksObserver
    }
}

extension ReactorV2 where T == Data {
    func fetch(with request: URLRequest) -> ReactorV2<T> {
        let values = tasks.value
        tasksObserver.send(<#T##event: Signal<[ReactorV2<Data>.Task], NoError>.Event##Signal<[ReactorV2<Data>.Task], NoError>.Event#>)
        return self
    }
}

extension ReactorV2 {
    typealias NetworkFlow = (URLRequest) -> SignalProducer<Data, ReactorError>
    typealias ParsingFlow = (Data) -> SignalProducer<T, ReactorError>
    typealias LoadFlow = (String) -> SignalProducer<T, ReactorError>
    typealias SaveFlow = (T, String) -> SignalProducer<T, ReactorError>

    enum Task {
        case network(NetworkFlow)
        case parsing(ParsingFlow)
        case load(LoadFlow)
        case save(SaveFlow)
    }
}


/*


 let reactor = Reactor<FooBar>.fetch(from:)



 */
