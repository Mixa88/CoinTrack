//
//  CoinDetailView.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 06.11.2025.
//

// CoinDetailView.swift
import SwiftUI

struct CoinDetailView: View {

    // 1. This View expects to receive a Coin from the list
    let coin: Coin

    var body: some View {
        // 2. We'll show the coin info we already have
        VStack {
            Text(coin.name)
                .font(.largeTitle)

            Text(coin.currentPrice.toCurrencyString())
                .font(.title)

            Text("Chart will go here!")
                .font(.caption)
                .foregroundStyle(.gray)
                .padding(.top, 50)

            Spacer()
        }
        .padding()
        .navigationTitle(coin.name) // Sets the title at the top
    }
}

#Preview {
    // 3. Use our mock coin for the preview
    CoinDetailView(coin: Coin.mock)
}
