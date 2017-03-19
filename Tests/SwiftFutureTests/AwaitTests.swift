//
// Created by Ryoichi Izumita on 2017/03/10.
//

import Foundation
import XCTest
import Dispatch
import Result
@testable import SwiftFuture

class AwaitTests: XCTestCase {

    func testAwaitOneFuture() {
        let future = Future<String, NoError> { observer in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                observer.send(value: "test")
            }
        }

        let value = try! Await.result(future, timeout: 2.0)
        XCTAssertEqual("test", value)

        let valueAgain = try! Await.result(future, timeout: 2.0)
        XCTAssertEqual("test", valueAgain)
    }

    func testAwaitOneFutureWithFailed() {
        let future = Future<String, TestingError> { observer in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                observer.send(failed: .failed)
            }
        }

        do {
            try Await.result(future, timeout: 1.0)
            XCTFail()
        } catch let error as TestingError {
            XCTAssertEqual(TestingError.failed, error)
        } catch let error as SwiftFutureError {
            XCTFail()
        } catch {
            XCTFail()
        }
    }

    func testAwaitOneFutureWithTimeout() {
        let future = Future<String, NoError> { observer in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                observer.send(value: "test")
            }
        }

        do {
            try Await.result(future, timeout: 0.5)
            XCTFail()
        } catch let error as SwiftFutureError {
            switch error {
            case .timedOut:
                XCTAssertTrue(true)
            default:
                XCTFail()
            }
        } catch {
            XCTFail()
        }
    }

    static var allTests: [(String, (AwaitTests) -> () throws -> Void)] {
        return [
            ("testAwaitOneFuture", testAwaitOneFuture),
            ("testAwaitOneFutureWithFailed", testAwaitOneFutureWithFailed),
            ("testAwaitOneFutureWithTimeout", testAwaitOneFutureWithTimeout),
        ]
    }

}
