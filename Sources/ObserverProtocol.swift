//
// Created by Ryoichi Izumita on 2017/03/09.
//

import Foundation

public protocol ObserverProtocol {
    associatedtype Value
    associatedtype Failed: Error

    func send(value: Value)

    func send(failed: Failed)
}
