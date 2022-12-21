import SwiftUI
import SwiftUIFlow

struct EventRowView: View {

    @ObservedObject var viewModel: EventRowViewModel

    init(viewModel: EventRowViewModel) {
        self.viewModel = viewModel
    }
    var body: some View {
        HStack(alignment: .top) {
            AsyncImage(
                url: viewModel.imageURL,
                content: { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                },
                placeholder: {
                    ProgressView()
                }
            )
            .frame(width: 56, height: 56)
            .background(Color.secondary.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(viewModel.eventTitle)
                    .font(.headline)
                Text(viewModel.eventDescription)
                    .font(.body)
                Text(viewModel.comicsCount)
                    .font(.footnote)

                VFlow(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.characterButtons) { buttonVM in
                        CharacterButton(viewModel: buttonVM)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
    }
}

import MarvelServiceMock
struct EventRowView_Previews: PreviewProvider {
    static var previews: some View {
        EventRowView(viewModel: .init(
            event: .init(
                id: 0,
                title: "Some title",
                eventDescription: "Some description",
                characters: .init(available: 1, returned: 1, collectionURI: "", items: [.init(resourceURI: "", name: "Hulk")]),
                comics: .init(available: 1, returned: 1, collectionURI: "", items: [.init(resourceURI: "", name: "")]),
                modified: Date(),
                thumbnail: .init(path: "", fileExtension: "")
            ),
            marvelService: MarvelServiceMock.dev
        ))
    }
}
