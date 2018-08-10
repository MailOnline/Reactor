import ReactiveSwift
import Result
import SystemConfiguration

/// Represents an entity that is able to check the connectivity.
public protocol Reachable {
    
    /// If it is connected
    func isConnected() -> SignalProducer<Bool, NoError>
}

/// A class able to check connectivity. Its implementation can be found here:
/// https://stackoverflow.com/questions/25623272/how-to-use-scnetworkreachability-in-swift/25623647#25623647
/// If it doesn't fit your needs, you can always use your implementation, by making it `Reachable` compliant.
public class Reachability: Reachable {
    
    public func isConnected() -> SignalProducer<Bool, NoError> {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return SignalProducer(value: false)
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return SignalProducer(value: false)
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return SignalProducer(value:isReachable && !needsConnection)
    }
}
