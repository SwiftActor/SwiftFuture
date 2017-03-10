//
// Created by Ryoichi Izumita on 2017/03/10.
//

import Foundation

enum SwiftFutureError: Error {
    case timeout
    case future(Error)
}
