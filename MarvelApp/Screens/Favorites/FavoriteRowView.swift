//
//  FavoriteRowView.swift
//  MarvelApp
//
//  Created by German Azcona on 12/20/22.
//

import SwiftUI

struct FavoriteRowView: View {

    @ObservedObject var viewModel: FavoriteRowViewModel

    var body: some View {
        HStack() {
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
                Text(viewModel.characterName)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.tapped?()
        }
    }
}

import MarvelServiceMock

struct FavoriteRowView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteRowView(viewModel: .init(characterID: 0, marvelService: MarvelServiceMock.dev))
    }
}
