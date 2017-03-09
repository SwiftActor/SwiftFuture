//
// Created by 和泉田 領一 on 2017/03/09.
//

import Foundation

public protocol ObserverProtocol {

    associatedtype Value
    associatedtype Failed

    func send(value: Value)

    func send(failed: Failed)

}
