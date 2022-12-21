import SwiftUI

struct EventsView: View {

    @ObservedObject var viewModel: EventsViewModel

    init(viewModel: EventsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            List(viewModel.rowViewModels) { rowViewModel in
                EventRowView(viewModel: rowViewModel)
                    .buttonStyle(PlainButtonStyle())
            }
            .overlay(content: {
                Text(viewModel.noResultsFound)
            })
            .listStyle(.plain)
        }
        .searchable(text: $viewModel.searchQuery, prompt: viewModel.searchPlaceholder)
        .onAppear { viewModel.onAppear() }
        .navigationTitle(viewModel.title)
        .alert(presenting: viewModel.dialogViewModel)
    }
}

import MarvelServiceMock

struct Events_Previews: PreviewProvider {
    static var previews: some View {
        EventsView(viewModel: .init(marvelService: MarvelServiceMock.dev))
    }
}
