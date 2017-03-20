import Foundation
import Result

public typealias OnCompleted<Value, Failed:Error> = (Result<Value, Failed>) -> ()
public typealias OnSuccess<Value> = (Value) -> ()
public typealias OnFailure<Failed:Error> = (Failed) -> ()

public protocol FutureProtocol {
    associatedtype Value
    associatedtype Failed: Error

    @discardableResult func onCompleted(_ completed: @escaping OnCompleted<Value, Failed>) -> Future<Value, Failed>

    @discardableResult func onSuccess(_ success: @escaping OnSuccess<Value>) -> Future<Value, Failed>

    @discardableResult func onFailure(_ failure: @escaping OnFailure<Failed>) -> Future<Value, Failed>

    func map<T>(_ transform: @escaping (Value) -> T) -> Future<T, Failed>
}

public struct Future<Value, Failed:Error> {

    fileprivate let observer: Observer<Value, Failed>

    public var result: Result<Value, Failed>? {
        return observer.result
    }

    public init(_ observe: (Observer<Value, Failed>) -> ()) {
        let observer = Observer<Value, Failed>()
        self.observer = observer
        observe(observer)
    }

}

extension Future: FutureProtocol {

    @discardableResult public func onCompleted(_ onCompleted: @escaping OnCompleted<Value, Failed>) -> Future<Value, Failed> {
        return Future<Value, Failed> { observer in
            self.observer.addChild(AnyObserver(observer: observer, transform: { $0 }, transformFailed: { $0 }))
            observer.setOnCompleted(onCompleted: onCompleted)
        }
    }

    @discardableResult public func onSuccess(_ onSuccess: @escaping OnSuccess<Value>) -> Future<Value, Failed> {
        return Future<Value, Failed> { observer in
            self.observer.addChild(AnyObserver(observer: observer, transform: { $0 }, transformFailed: { $0 }))
            observer.setOnSuccess(onSuccess: onSuccess)
        }
    }

    @discardableResult public func onFailure(_ onFailure: @escaping OnFailure<Failed>) -> Future<Value, Failed> {
        return Future<Value, Failed> { observer in
            self.observer.addChild(AnyObserver(observer: observer, transform: { $0 }, transformFailed: { $0 }))
            observer.setOnFailure(onFailure: onFailure)
        }
    }

    public func map<T>(_ transform: @escaping (Value) -> T) -> Future<T, Failed> {
        return Future<T, Failed> { observer in
            self.observer.addChild(AnyObserver(observer: observer, transform: transform, transformFailed: { $0 }))
            self.onCompleted { (result: Result<Value, Failed>) in
                switch result {
                case .success(let value): observer.send(value: transform(value))
                case .failure(let error): observer.send(failed: error)
                }
            }
        }
    }
}

class AnyObserver<Value, Failed:Error> {

    private let sendValue:  (Value) -> ()
    private let sendFailed: (Failed) -> ()

    init<NewValue, NewFailed>(observer: Observer<NewValue, NewFailed>,
                              transform: @escaping (Value) -> NewValue,
                              transformFailed: @escaping ((Failed) -> NewFailed)) {
        sendValue = { observer.send(value: transform($0)) }
        sendFailed = { observer.send(failed: transformFailed($0)) }
    }

    func send(value: Value) {
        sendValue(value)
    }

    func send(failed: Failed) {
        sendFailed(failed)
    }

}
