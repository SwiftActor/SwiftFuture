//
// Created by Ryoichi Izumita on 2017/03/10.
//

import Foundation
import Dispatch
import Result

public struct Await<FutureType:FutureProtocol> {

    public static func result(_ future: FutureType, timeout: TimeInterval) throws -> FutureType.Value {
        var result:   Result<FutureType.Value, FutureType.Failed>?
        let group = DispatchGroup()
        group.enter()
        future.onCompleted { completedResult in
            result = completedResult
            group.leave()
        }

        switch group.wait(timeout: .now() + timeout) {
        case .success:
            switch result {
            case .success(let value)?:
                return value
            case .failure(let error)?:
                throw error
            default:
                throw SwiftFutureError.unknown
            }
        case .timedOut:
            throw SwiftFutureError.timedOut
        }
    }

}
