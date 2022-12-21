//
//  PushNotificationView.swift
//  MarvelApp
//
//  Created by German Azcona on 12/20/22.
//

import SwiftUI

struct CharacterPushNotificationView: View {
    var body: some View {
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
        }
    }
}

struct PushNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        PushNotificationView()
    }
}
