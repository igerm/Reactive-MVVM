import APIService
import Combine
import Foundation

final public class APIServiceMock: APIService {

    public let dataPublisher = FutureMock<Data, Error>()

    public func dataPublisher(for request: APIRequest) -> Future<Data, Error> {
        dataPublisher.future()
    }

    public init() {}
}

/// Let's you mock a `Future` `Publisher`.
/// You create the mock and return it's `.future()`.
/// Then, you can manually trigger a value for the future publisher by calling `fulfill`. Whoever got the
/// first `.future()` will get the value you just fulfilled.
final public class FutureMock<T, ErrorT: Error> {
    private var promisesStack: [Future<T, ErrorT>.Promise] = []

    public init() {}

    public func future() -> Future<T, ErrorT> {
        return .init({ promise in
            self.promisesStack.append(promise)
        })
    }

    public func fulfill(_ resultToForce: Result<T, ErrorT>, file: StaticString = #file, line: UInt = #line) {
        guard let promise = promisesStack.first else { return }
        promise(resultToForce)
        promisesStack = Array(promisesStack.dropFirst())
    }
}
