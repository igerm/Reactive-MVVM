//
//  MarvelApp.swift
//  MarvelApp
//
//  Created by German Azcona on 12/12/22.
//

import SwiftUI

@main
struct MarvelApp: App {

    let diContainer: DIContainer
    @ObservedObject var appModel: AppModel

    init() {

        let container = SwinjectDIContainer()
        container.registerLiveDependencies()

        self.diContainer = container
        self.appModel = AppModel(diContainer: container)
    }

    var body: some Scene {
        WindowGroup {
            TabView(selection: $appModel.selection) {
                ForEach(appModel.tabs) { screen in
                    switch screen {
                    case .characters(let viewModel):
                        NavigationView {
                            CharactersView(viewModel: viewModel)
                                .navigationTitle(viewModel.title)
                        }
                        .tabItem { Label(viewModel.title, systemImage: "person.3.fill") }
                        .tag(0)

                    case .events(let viewModel):
                        NavigationView {
                            EventsView(viewModel: viewModel)
                        }
                        .tabItem { Label(viewModel.title, systemImage: "calendar") }
                        .tag(1)

                    case .favorites(let viewModel):
                        NavigationView {
                            FavoritesView(viewModel: viewModel)
                        }
                        .tabItem { Label(viewModel.title, systemImage: "star") }
                        .tag(2)
                    }
                }
            }
            .sheet(item: $appModel.present) { screen in
                switch screen {
                case .character(let viewModel):
                    CharacterDetailsView(viewModel: viewModel)
                }
            }
        }
    }
}

import CharacterDetailsView

final class AppModel: ObservableObject {

    enum TabScreen: Identifiable {

        case characters(CharactersViewModel)
        case events(EventsViewModel)
        case favorites(FavoritesViewModel)

        // MARK: - Identifiable
        var id: String {
            switch self {
            case .characters: return "characters"
            case .events: return "events"
            case .favorites: return "favorites"
            }
        }
    }

    /// Screens to be presented
    enum PresentScreen: Identifiable {

        case character(CharacterDetailsViewModel)

        // MARK: - Identifiable
        var id: String {
            switch self {
            case .character: return "character"
            }
        }
    }

    @Published var selection: Int = 0
    @Published private(set) var tabs: [TabScreen] = []

    @Published var present: PresentScreen?

    var diContainer: DIContainer

    public init(diContainer: DIContainer) {
        self.diContainer = diContainer

        tabs = [
            .characters(makeCharactersVM()),
            .events(makeEventsVM()),
            .favorites(makeFavoritesVM())
        ]
    }

    private func makeCharactersVM() -> CharactersViewModel {
        let vm = CharactersViewModel(marvelService: diContainer.resolve())
        vm.showCharacter = { [weak self] id in
            self?.presentCharacter(id: id)
        }
        return vm
    }

    private func makeEventsVM() -> EventsViewModel {
        let vm = EventsViewModel(marvelService: diContainer.resolve())
        vm.showCharacter = { [weak self] id in
            self?.presentCharacter(id: id)
        }
        return vm
    }

    private func presentCharacter(id: Int64) {
        self.present = .character(
            CharacterDetailsViewModel(characterID: id, marvelService: diContainer.resolve())
        )
    }

    private func makeFavoritesVM() -> FavoritesViewModel {
        let vm = FavoritesViewModel(marvelService: diContainer.resolve())
        vm.showCharacter = { [weak self] id in
            self?.presentCharacter(id: id)
        }
        return vm
    }
}
