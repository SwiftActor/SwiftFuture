//: Playground - noun: a place where people can play

import Foundation
import Dispatch
import SwiftFuture
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

enum MyError: Error {
    case error
}

let future = Future<String, MyError> { observer in
    DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
        observer.send(value: "playground")
    }
}

future.onSuccess { value in
    print("value: " + value)
}.onFailure { error in
    print("not called")
}.onCompleted { result in
    print(result)
}.onCompleted { _ in
    print("completed")
}

let value = try! Await.result(future, timeout: 2.0)
print("Await: " + value)

let valueAgain = try! Await.result(future, timeout: 2.0)
print("Await again: " + valueAgain)



let failedFuture = Future<String, MyError> { observer in
    DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
        observer.send(failed: .error)
    }
}

failedFuture.onSuccess { value in
    print("not called")
}.onFailure { error in
    print(error)
}.onCompleted { result in
    print(result)
}

do {
    let value = try Await.result(failedFuture, timeout: 3.0)
    print("not called")
} catch let e {
    print(e)
}


let timedOutFuture = Future<String, MyError> { observer in
    DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
        observer.send(failed: .error)
    }
}

do {
    let value = try Await.result(timedOutFuture, timeout: 0.5)
    print("not called")
} catch let e{
    print(e)
}
