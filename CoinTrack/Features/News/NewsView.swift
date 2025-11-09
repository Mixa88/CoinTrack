//
//  NewsView.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 09.11.2025.
//

import SwiftUI

struct NewsView: View {
    var body: some View {
        NavigationStack {
            Text("Crypto News will be here!") // TODO: Localize
                .navigationTitle("News") // TODO: Localize
        }
    }
}

#Preview {
    NewsView()
}
