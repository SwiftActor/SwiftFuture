//
// Created by Ryoichi Izumita on 2017/03/10.
//

import Foundation
import Dispatch

public enum Await<F:FutureProtocol> {
    case waiting
    case observed(F.Value)
    case failed(Error)

    public static func result(_ future: F, timeout: TimeInterval) throws -> F.Value {
        var state    = Await<F>.waiting
        let setState = set(state)

        let group = DispatchGroup()
        group.enter()

        future.onCompleted { result in
            switch result {
            case .success(let value):
                state = setState(.observed(value))
            case .failure(let error):
                state = setState(.failed(error))
            }
            group.leave()
        }

        _ = group.wait(timeout: .now() + timeout)

        if case let .observed(value) = state {
            return value
        } else if case let .failed(error) = state {
            throw SwiftFutureError.future(error)
        } else {
            throw SwiftFutureError.timeout
        }
    }

    fileprivate static func set(_ initialState: Await<F>) -> (Await<F>) -> Await<F> {
        var state = initialState
        var dirty = false
        let queue = DispatchQueue.global()

        return { newState in
            queue.sync {
                if dirty == false {
                    state = newState
                }

                switch state {
                case .observed(_), .failed(_):
                    dirty = true
                default: ()
                }
                return state
            }
        }
    }

}
