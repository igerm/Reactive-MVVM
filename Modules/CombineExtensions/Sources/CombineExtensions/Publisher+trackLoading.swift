import Combine
import Foundation

public extension Publisher {

    @available(iOS 14.0, macOS 11.0, *)
    func trackLoading(to published: inout Published<Bool>.Publisher) -> Publishers.HandleEvents<Self> {
        let subject = PassthroughSubject<Bool, Never>()
        subject
            .assign(to: &published)

        return handleEvents(
            receiveSubscription: { _ in
                subject.send(true)
            },
            receiveOutput: { _ in
                subject.send(false)
            },
            receiveCompletion: { _ in
                subject.send(false)
            },
            receiveCancel: {
                subject.send(false)
            }
        )
    }

    /// Simplified loading tracking
    func trackLoading<Root>(
        to keyPath: ReferenceWritableKeyPath<Root, Bool>,
        onWeak object: Root
    ) -> Publishers.HandleEvents<Self> where Root: AnyObject {
        handleEvents(
            receiveSubscription: { [weak object] _ in
                object?[keyPath: keyPath] = true
            },
            receiveOutput: { [weak object] _ in
                object?[keyPath: keyPath] = false
            },
            receiveCompletion: { [weak object] _ in
                object?[keyPath: keyPath] = false
            },
            receiveCancel: { [weak object] in
                object?[keyPath: keyPath] = false
            }
        )
    }

    func onError(_ closure: @escaping(Failure) -> Void) -> Publishers.HandleEvents<Self> {
        handleEvents(
            receiveCompletion: { completion in
                guard case .failure(let error) = completion else { return }
                closure(error)
            }
        )
    }
}
