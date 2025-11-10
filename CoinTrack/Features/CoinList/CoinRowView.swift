//
//  CoinRowView.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 06.11.2025.
//


import SwiftUI

struct CoinRowView: View {
    
    // 1. This View is "dumb". It just receives one coin and displays it.
    let coin: Coin
    
    var body: some View {
        HStack(spacing: 12) {
            
            // --- 2. Coin Image (AsyncImage handles the download) ---
            AsyncImage(url: URL(string: coin.image)) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                // Show a circle while loading
                Circle()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(Color(.systemGray5))
            }
            .frame(width: 32, height: 32)
            
            // --- 3. Name and Symbol ---
            VStack(alignment: .leading, spacing: 4) {
                Text(coin.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(coin.symbol.uppercased())
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            
            Spacer() // Pushes everything to the left and right
            
            // --- 4. Price and 24h Change ---
            VStack(alignment: .trailing, spacing: 4) {
                Text(coin.currentPrice.toCurrencyString())
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text((coin.priceChangePercentage24H ?? 0).toPercentString()) // <-- ADD ?? 0
                    .font(.caption)
                    .foregroundStyle((coin.priceChangePercentage24H ?? 0) >= 0 ? .green : .red)
            }
        }
        .padding(.vertical, 8) // Add some "cozy" vertical space
    }
}



// CoinRowView.swift
#Preview {
    VStack(spacing: 20) {
        CoinRowView(coin: Coin.mock)
        CoinRowView(coin: Coin.mock2)
    }
    .padding()
}
