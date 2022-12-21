import Combine
import Foundation
import MarvelService
import MarvelLocalization

final class EventsViewModel: ObservableObject {

    @Published public private(set) var title: String = L10n.Events.title
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var rowViewModels: [EventRowViewModel] = []
    @Published private var allRowViewModels: [EventRowViewModel] = []
    @Published public var dialogViewModel: DialogViewModel? = nil
    @Published public var searchQuery: String = ""
    @Published public var searchPlaceholder: String = L10n.Events.Search.placeholder
    @Published public private(set) var noResultsFound: String = ""

    public var showCharacter: ((Int64) -> Void)?

    private let marvelService: MarvelService
    private var cancellables: Set<AnyCancellable> = []

    init(marvelService: MarvelService) {
        self.marvelService = marvelService
        setupBindings()
    }

    func onAppear() {
        guard rowViewModels.isEmpty && !isLoading else { return }
        loadEvents()
    }

    private func loadEvents() {
        marvelService
            .events(named: nil)
            .receive(on: DispatchQueue.main)
            .trackLoading(to: &$isLoading)
            .map { [weak self, marvelService] events in
                return events.map {
                    EventRowViewModel(
                        event: $0,
                        onCharacterSelection: { [weak self] id in
                            self?.showCharacter?(id)
                        },
                        marvelService: marvelService
                    )
                }
            }
            .onError { [weak self] error in
                self?.dialogViewModel = .error()
            }
            .sink { completion in
                print("completed")
            } receiveValue: { [weak self] rowVMs in
                self?.allRowViewModels = rowVMs
                print("got \(rowVMs.count) events")
            }
            .store(in: &cancellables)
    }

    private func setupBindings() {
        Publishers
            .CombineLatest(
                $allRowViewModels,
                $searchQuery//.debounce(for: .seconds(0.05), scheduler: DispatchQueue.main)
            )
            .map { allRows, query in
                let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
                guard query.isEmpty == false else { return allRows }
                return allRows.filter { row in
                    return row.eventTitle.contains(query) || row.eventDescription.contains(query)
                }
            }
            .assign(to: &$rowViewModels)

        Publishers
            .CombineLatest($rowViewModels, $searchQuery)
            .map { visibleRows, query -> String in
                let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !query.isEmpty && visibleRows.isEmpty else { return "" }
                return L10n.Events.Search.noResults
            }
            .assign(to: &$noResultsFound)
    }
}
