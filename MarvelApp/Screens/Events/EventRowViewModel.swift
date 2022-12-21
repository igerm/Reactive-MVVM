import Foundation
import MarvelService
import MarvelLocalization

final class EventRowViewModel: Identifiable, Hashable, ObservableObject {

    let id: Int64

    @Published public private(set) var imageURL: URL?
    @Published public private(set) var eventTitle: String = "Title title title"
    @Published public private(set) var eventDescription: String = "Description description"
    @Published public private(set) var comicsCount: String = "13 comics"
    @Published public private(set) var characterButtons: [CharacterButtonViewModel] = []

    var onCharacterSelection: ((Int64) -> Void)?

    init(
        event: Event,
        onCharacterSelection: ((Int64) -> Void)? = nil,
        marvelService: MarvelService
    ) {

        id = event.id
        imageURL = event.thumbnail.url
        eventTitle = event.title
        eventDescription = event.eventDescription
        comicsCount = L10n.Events.Cell.ComicsLabel.count(Int(event.comics.available))

        characterButtons = event.characters
            .items
            .compactMap { [weak self] character -> CharacterButtonViewModel? in
                guard let id = character.id else { return nil }
                let buttonViewModel = CharacterButtonViewModel(
                    characterID: id,
                    name: character.name,
                    marvelService: marvelService
                )
                buttonViewModel.tapped = { [weak self] in
                    self?.onCharacterSelection?(id)
                }
                return buttonViewModel
            }
        if characterButtons.count > 1 {
            characterButtons.last?.isLastButton = true
        }
        self.onCharacterSelection = onCharacterSelection
    }

    // MARK: - Hashable

    static func == (lhs: EventRowViewModel, rhs: EventRowViewModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
