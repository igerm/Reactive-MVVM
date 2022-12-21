import Combine

public extension Publisher where Self.Failure == Never {

    /// Assign non optional to optional
    func assign<Root>(to keyPath: ReferenceWritableKeyPath<Root, Self.Output?>, on object: Root) -> AnyCancellable {
        map { $0 as Self.Output? }
            .assign(to: keyPath, on: object)
    }
}
