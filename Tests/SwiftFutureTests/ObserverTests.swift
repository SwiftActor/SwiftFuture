import XCTest
import Dispatch
@testable import SwiftFuture

class ObserverTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSetOnCompleted() {
        let exp = expectation(description: "testOnCompleted")
        let observer = Observer<Int, TestingError>()
        observer.setOnCompleted { result in
            XCTAssertEqual(1, result.value!)
            exp.fulfill()
        }
        observer.send(value: 1)

        waitForExpectations(timeout: 2.0)
    }

    func testSetOnSuccess() {
        let exp = expectation(description: "testSetOnSuccess")
        let observer = Observer<Int, TestingError>()
        observer.setOnSuccess { value in
            XCTAssertEqual(1, value)
            exp.fulfill()
        }
        observer.send(value: 1)

        waitForExpectations(timeout: 2.0)
    }

    func testSetOnFailure() {
        let exp = expectation(description: "testSetOnFailure")
        let observer = Observer<Int, TestingError>()
        observer.setOnFailure { error in
            XCTAssertEqual(TestingError.failed, error)
            exp.fulfill()
        }
        observer.send(failed: .failed)

        waitForExpectations(timeout: 2.0)
    }

}
