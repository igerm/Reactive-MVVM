import SwiftUI

struct FavoritesView: View {

    @ObservedObject var viewModel: FavoritesViewModel

    init(viewModel: FavoritesViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            List(viewModel.rowViewModels) { rowViewModel in
                FavoriteRowView(viewModel: rowViewModel)
                    .buttonStyle(PlainButtonStyle())
                    .listRowInsets(EdgeInsets())
            }
            .listStyle(.plain)
        }
        .navigationTitle(viewModel.title)
    }
}

import MarvelServiceMock

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView(viewModel: .init(marvelService: MarvelServiceMock.dev))
    }
}
