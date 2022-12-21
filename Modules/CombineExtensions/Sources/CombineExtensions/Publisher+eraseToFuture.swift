import Combine

public extension Publisher {

    /// Wraps the first value of the current publisher in a Future.
    func eraseToFuture() -> Future<Output, Failure> {
        return Future { promise in
            var cancellable: AnyCancellable?
            cancellable = first()
                .sink(
                    receiveCompletion: {
                        cancellable?.cancel()
                        cancellable = nil
                        switch $0 {
                        case .failure(let error):
                            promise(.failure(error))
                        case .finished:
                            break // We only fulfill the promise once, when we get a value.
                        }
                    },
                    receiveValue: {
                        cancellable?.cancel()
                        cancellable = nil
                        promise(.success($0))
                    }
                )
        }
    }
}
