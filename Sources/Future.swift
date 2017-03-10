import Foundation
import Result

public protocol FutureProtocol {
    associatedtype Value
    associatedtype Failed: Error

    @discardableResult func onCompleted(_ completed: @escaping (Result<Value, Failed>) -> ()) -> Future<Value, Failed>

    @discardableResult func onSuccess(_ success: @escaping (Value) -> ()) -> Future<Value, Failed>

    @discardableResult func onFailure(_ failure: @escaping (Failed) -> ()) -> Future<Value, Failed>
}

public struct Future<T, E:Error>: FutureProtocol {

    public typealias Value = T
    public typealias Failed = E

    let observer: Observer<Value, Failed>

    public init(_ observe: (Observer<Value, Failed>) -> ()) {
        self.observer = Observer<Value, Failed>()
        observe(self.observer)
    }

    @discardableResult public func onCompleted(_ completed: @escaping (Result<T, E>) -> ()) -> Future<T, E> {
        observer.onCompleted = completed
        return self
    }

    @discardableResult public func onSuccess(_ success: @escaping (T) -> ()) -> Future<T, E> {
        observer.onSuccess = success
        return self
    }

    @discardableResult public func onFailure(_ failure: @escaping (E) -> ()) -> Future<T, E> {
        observer.onFailure = failure
        return self
    }

}
