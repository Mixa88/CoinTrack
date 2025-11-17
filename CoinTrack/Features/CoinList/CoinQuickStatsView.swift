//
//  CoinQuickStatsView.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 09.11.2025.
//


import SwiftUI

struct CoinQuickStatsView: View {
    
    // It just receives a coin
    let coin: Coin
    
    var body: some View {
        // We use our "card" style
        VStack(alignment: .leading, spacing: 12) {
            
            // --- Header ---
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: coin.image)) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Circle().foregroundStyle(Color(.systemGray5))
                }
                .frame(width: 32, height: 32)
                
                VStack(alignment: .leading) {
                    Text(coin.name)
                        .font(.headline)
                    Text(coin.symbol.uppercased())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Divider()
            
            // --- Stats ---
            StatisticRowView(
                    
                    title: NSLocalizedString("detail.statistics.market_cap", comment: ""),
                    value: (coin.marketCap ?? 0).toFormattedString()
                )
                StatisticRowView(
                    
                    title: NSLocalizedString("detail.statistics.high_24h", comment: ""),
                    value: (coin.high24H ?? 0).toCurrencyString()
                )
                StatisticRowView(
                    
                    title: NSLocalizedString("detail.statistics.low_24h", comment: ""),
                    value: (coin.low24H ?? 0).toCurrencyString()
                )
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .frame(maxWidth: 300) // Constrain the width for a "pop-up" feel
    }
}

#Preview {
    CoinQuickStatsView(coin: Coin.mock)
}
