//
// Created by Ryoichi Izumita on 2017/03/09.
//

import Foundation
import Dispatch
import Result

protocol InquirerProtocol {
    associatedtype Value
    associatedtype Failed: Error

    func observed(result: Result<Value, Failed>)
}

public class Observer<Value, Failed:Error> {
    internal var result: Result<Value, Failed>? {
        didSet {
            queue.async {
                self.notify()
            }
        }
    }

    fileprivate var onCompleted: OnCompleted<Value, Failed>?
    fileprivate var onSuccess:   OnSuccess<Value>?
    fileprivate var onFailure:   OnFailure<Failed>?

    fileprivate var children = [AnyObserver<Value, Failed>]()
    fileprivate let queue    = DispatchQueue(label: "SwiftFuture.Observer.queue")

    internal func setOnCompleted(onCompleted: @escaping OnCompleted<Value, Failed>) {
        queue.async {
            self.onCompleted = onCompleted
            self.notify()
        }
    }

    internal func setOnSuccess(onSuccess: @escaping OnSuccess<Value>) {
        queue.async {
            self.onSuccess = onSuccess
            self.notify()
        }
    }

    internal func setOnFailure(onFailure: @escaping OnFailure<Failed>) {
        queue.async {
            self.onFailure = onFailure
            self.notify()
        }
    }

    private func notify() {
        guard let result = result else { return }

        if let completed = onCompleted {
            completed(result)
            self.onCompleted = .none
        }

        switch result {
        case .success(let value):
            if let success = onSuccess {
                success(value)
                self.onSuccess = .none
            }
            children.forEach { child in child.send(value: value) }
            children = []

        case .failure(let error):
            if let failure = onFailure {
                failure(error)
                self.onFailure = .none
            }
            children.forEach { child in child.send(failed: error) }
            children = []
        }
    }

    func addChild(_ observer: AnyObserver<Value, Failed>) {
        queue.async {
            self.children.append(observer)
            switch self.result {
            case .success(let value)?:
                observer.send(value: value)
            case .failure(let error)?:
                observer.send(failed: error)
            default: ()
            }
        }
    }
}

extension Observer: ObserverProtocol {

    public func send(value: Value) {
        self.result = .success(value)
    }

    public func send(failed: Failed) {
        self.result = .failure(failed)
    }

}
