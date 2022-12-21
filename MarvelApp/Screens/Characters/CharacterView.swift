import SwiftUI

struct CharactersView: UIViewControllerRepresentable {

    typealias UIViewControllerType = CharactersViewController

    private let viewModel: CharactersViewModel

    init(viewModel: CharactersViewModel) {
        self.viewModel = viewModel
    }

    func makeUIViewController(context: Context) -> UIViewControllerType {
        let viewController = CharactersViewController(viewModel: viewModel)
        context.coordinator.parentObserver = viewController.observe(\.parent, changeHandler: { vc, _ in
            vc.parent?.title = vc.title
            vc.parent?.navigationItem.titleView = vc.navigationItem.titleView
        })
        return viewController
    }

    func updateUIViewController(_ vc: UIViewControllerType, context: Context) {
    }

    func makeCoordinator() -> Self.Coordinator { Coordinator() }

    class Coordinator {
        var parentObserver: NSKeyValueObservation?
    }
}

import MarvelServiceMock

struct CharactersView_Previews: PreviewProvider {

    static var previews: some View {
        NavigationView {
            CharactersView(viewModel: CharactersViewModel(marvelService: MarvelServiceMock.dev))
                //.navigationTitle("Test")
                //.navigationBarTitleDisplayMode(.inline)
        }
    }
}
