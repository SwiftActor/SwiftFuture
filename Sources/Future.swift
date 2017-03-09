import Result

public struct Future<T, E:Error> {

    let observer: Observer<T, E>

    public init(_ observe: (Observer<T, E>) -> ()) {
        self.observer = Observer()
        observe(observer)
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
