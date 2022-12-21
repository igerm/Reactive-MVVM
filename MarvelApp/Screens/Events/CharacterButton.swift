import SwiftUI

struct CharacterButton: View {

    @ObservedObject private(set) var viewModel: CharacterButtonViewModel

    init(viewModel: CharacterButtonViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Button {
            viewModel.tapped?()
        } label: {
            Text(viewModel.text)
            .padding(EdgeInsets(top: 2, leading: 0, bottom: 4, trailing: 0))
        }
    }
}

import Combine
import MarvelService

final class CharacterButtonViewModel: ObservableObject, Identifiable {

    let id: Int64
    @Published private(set) var text: AttributedString = ""
    @Published private(set) var isFavorite: Bool = false
    @Published var isLastButton: Bool = false

    var tapped: (() -> Void)?

    @Published private var character: Character? = nil
    @Published private var name: String
    private let marvelService: MarvelService?
    private var cancellables: Set<AnyCancellable> = []

    init(characterID: Int64, name: String, marvelService: MarvelService) {
        self.id = characterID
        self.name = name
        self.marvelService = marvelService
        reloadText()
        setupBindings()
    }

    func setupBindings() {

        guard let marvelService = marvelService else { return }

        marvelService.character(id: id, refreshData: false)
            .sink { _ in
            } receiveValue: { [weak self] character in
                self?.character = character
            }
            .store(in: &cancellables)

        $character
            .compactMap { $0?.name }
            .assign(to: &$name)

        $character
            .compactMap { $0?.isFavorite ?? false }
            .assign(to: &$isFavorite)

        Publishers.CombineLatest3($name, $isFavorite, $isLastButton)
            .debounce(for: 0.1, scheduler: DispatchQueue.main)
            .sink { [weak self] _, _, _ in
                self?.reloadText()
            }
            .store(in: &cancellables)
    }

    func reloadText() {
        if name == "Alpha Flight" {
            print("stop")
        }
        var prefix = AttributedString(isLastButton ? "and ": "")
        prefix.foregroundColor = .primary
        var name = AttributedString(name)
        name.foregroundColor = isFavorite ? .yellow : .blue
        var sufix = AttributedString(isLastButton ? "." : ", ")
        sufix.foregroundColor = .primary
        text = prefix + name + sufix
    }
}
