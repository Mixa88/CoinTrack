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
                
                Text(coin.priceChangePercentage24H.toPercentString())
                    .font(.caption)
                    .foregroundStyle(coin.priceChangePercentage24H >= 0 ? .green : .red)
            }
        }
        .padding(.vertical, 8) // Add some "cozy" vertical space
    }
}

// --- 5. A small extension to format our numbers nicely ---
// We can move this to a new file in `Core/Extensions` later.
extension Double {
    
    /// Converts a Double into a Currency String with 2 decimal places.
    /// ```
    /// Example: 1234.56 -> "$1,234.56"
    /// ```
    func toCurrencyString() -> String {
        return self.formatted(.currency(code: "usd").precision(.fractionLength(2)))
    }
    
    /// Converts a Double into a Percent String with 2 decimal places.
    /// ```
    /// Example: 1.23 -> "1.23%"
    /// ```
    func toPercentString() -> String {
        return (self / 100.0).formatted(.percent.precision(.fractionLength(2)))
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
