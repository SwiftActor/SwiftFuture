//
// Created by Ryoichi Izumita on 2017/03/09.
//

import Foundation
import Result

public class Observer<T, E:Error> {
    internal var result: Result<T, E>? {
        didSet {
            notify()
        }
    }

    internal var onCompleted: ((Result<T, E>) -> ())? {
        didSet {
            notify()
        }
    }

    internal var onSuccess: ((T) -> ())? {
        didSet {
            notify()
        }
    }

    internal var onFailure: ((E) -> ())? {
        didSet {
            notify()
        }
    }

}

extension Observer: ObserverProtocol {

    public func send(value: T) {
        result = .success(value)
    }

    public func send(failed: E) {
        result = .failure(failed)
    }

}

extension Observer {

    fileprivate func notify() {
        guard let result = result else { return }

        onCompleted?(result)
        if let value = result.value { onSuccess?(value) }
        if let error = result.error { onFailure?(error) }
    }

}
