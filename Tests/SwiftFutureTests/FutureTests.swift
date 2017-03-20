import XCTest
import Dispatch
import Result
@testable import SwiftFuture

enum TestingError: Error {
    case failed
}

class FutureTests: XCTestCase {
    func testOnComplete() {
        let exp = expectation(description: "Future")

        let future = Future<String, NoError> { observer in
            DispatchQueue.global().async {
                observer.send(value: "test")
            }
        }

        future.onCompleted { result in
            XCTAssertEqual("test", result.value!)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testOnSuccess() {
        let exp = expectation(description: "Future")

        let future = Future<String, NoError> { observer in
            DispatchQueue.global().async {
                observer.send(value: "test")
            }
        }

        future.onSuccess { value in
            XCTAssertEqual("test", value)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testOnFailure() {
        let exp = expectation(description: "Future")

        let future = Future<String, TestingError> { observer in
            DispatchQueue.global().async {
                observer.send(failed: .failed)
            }
        }

        future.onSuccess { value in
            XCTFail()
        }.onFailure { error in
            XCTAssertEqual(TestingError.failed, error)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testMap() {
        let exp = expectation(description: "testMap")

        let future = Future<Int, TestingError> { observer in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                observer.send(value: 1)
            }
        }

        let mappedFuture = future.map { num in String(num) }
                                 .onSuccess { value in
                                     XCTAssertEqual("1", value)
                                     exp.fulfill()
                                 }

        waitForExpectations(timeout: 2.0)
    }

    static var allTests: [(String, (FutureTests) -> () throws -> Void)] {
        return [
            ("testOnComplete", testOnComplete),
            ("testOnSuccess", testOnSuccess),
            ("testOnFailure", testOnFailure),
        ]
    }
}
