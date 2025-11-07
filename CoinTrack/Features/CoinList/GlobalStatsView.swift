//
//  GlobalStatsView.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 07.11.2025.
//

import SwiftUI

struct GlobalStatsView: View {
    
    // 1. This View is "dumb". It just receives data.
    let data: GlobalData
    
    var body: some View {
        // 2. We use a "cozy" horizontal scroll
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                // 3. We create a "helper" view for each stat
                StatisticItemView(
                    title: "Market Cap",
                    value: (data.marketCapUSD).toFormattedString()
                )
                
                StatisticItemView(
                    title: "Total Volume",
                    value: (data.volumeUSD).toFormattedString()
                )
                
                StatisticItemView(
                    title: "BTC Dominance",
                    value: (data.btcDominance).toDominanceString()
                )
            }
            .padding(.horizontal) // Add padding so it doesn't touch the edges
            .padding(.vertical, 8) // A bit of top/bottom padding
        }
    }
}

// --- 4. Helper View for each item ---
struct StatisticItemView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    // Create mock data
    let mockGlobalData = GlobalData(
        totalMarketCap: ["usd": 1234567890123.0],
        totalVolume: ["usd": 150000000000.0],
        marketCapPercentage: ["btc": 45.1234]
    )
    
    return GlobalStatsView(data: mockGlobalData)
}
