import MarvelService
import MarvelServiceMock
import SwiftUI

public struct CharacterDetailsView: View {

    @ObservedObject var viewModel: CharacterDetailsViewModel

    public init(characterID: Int64, marvelService: MarvelService) {
        viewModel = .init(characterID: characterID, marvelService: marvelService)
    }

    public init(viewModel: CharacterDetailsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                AsyncImage(
                    url: viewModel.avatarURL,
                    content: { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    },
                    placeholder: {
                        ProgressView()
                    }
                )
                .frame(width: 80, height: 80)
                .background(Color.secondary.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading) {
                    Text(viewModel.isLoading ? "Loading loading loading" : viewModel.title)
                        .font(.title)
                    Text(viewModel.isLoading ? "Last updated: Jan 1, 2000 at 00:00 PM" : viewModel.lastUpdated)
                        .font(.callout)
                }

                Spacer()

                Button {
                    viewModel.favoriteTapped()
                } label: {
                    Image(systemName: viewModel.isFavorite ? "star.fill" : "star")
                        .renderingMode(.original)
                }
                .frame(width: 44, height: 44)

            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(viewModel.isLoading ? "Loading loading loading loading loading loading loading loading loading loading loading loading loading loading loading loading loading loading loading loading loading loading" : viewModel.description)
                .font(.body)

            Divider()

            Text(viewModel.isLoading ? "Loading loading loading loading loading loading loading loading loading loading loading loading loading loading" : viewModel.eventsTitle)
                .font(.headline)
            Text(viewModel.isLoading ? "Loading loading loading loading loading loading loading loading loading loading loading loading loading loading" : viewModel.eventsDescription)
                .font(.body)

            Spacer()
        }
        .padding(EdgeInsets(top: 30, leading: 20, bottom: 30, trailing: 20))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .redacted(reason: viewModel.isLoading ? .placeholder : [])
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterDetailsView(
            characterID: 10,
            marvelService: MarvelServiceMock.dev
        )
    }
}
