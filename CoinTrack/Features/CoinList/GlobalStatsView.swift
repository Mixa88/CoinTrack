//
//  GlobalStatsView.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 07.11.2025.
//

import SwiftUI

struct GlobalStatsView: View {
    
    
    let globalData: GlobalData
    let fearGreedData: FearGreedData?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                
                
                StatisticItemView(
                    title: "Market Cap",
                    value: (globalData.marketCapUSD).toFormattedString()
                )
                
                StatisticItemView(
                    title: "Total Volume",
                    value: (globalData.volumeUSD).toFormattedString()
                )
                
                StatisticItemView(
                    title: "BTC Dominance",
                    value: (globalData.btcDominance).toDominanceString()
                )
                
              
                
                if let fearGreed = fearGreedData {
                    StatisticItemView(
                        title: fearGreed.valueClassification, // "Fear", "Greed" etc.
                        value: fearGreed.value // "42", "69" etc.
                    )
                }
                
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
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
    
    let mockGlobalData = GlobalData(
        totalMarketCap: ["usd": 1234567890123.0],
        totalVolume: ["usd": 150000000000.0],
        marketCapPercentage: ["btc": 45.1234]
    )
    
    let mockFearGreedData = FearGreedData(
        value: "55",
        valueClassification: "Neutral"
    )
    
    return GlobalStatsView(globalData: mockGlobalData, fearGreedData: mockFearGreedData)
}
