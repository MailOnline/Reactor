import enum Result.NoError
import ReactiveSwift

struct AlwaysReachable: Reachable {
    func isConnected() -> SignalProducer<Bool, NoError> {
        return SignalProducer(value: true)
    }
}
