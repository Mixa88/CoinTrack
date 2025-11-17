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
            
            // --- 1. SET SPACING TO 12 (Friend's suggestion) ---
            HStack(spacing: 12) {
                
                StatisticItemView(
                        
                        title: NSLocalizedString("detail.statistics.market_cap", comment: ""),
                        value: (globalData.marketCapUSD).toFormattedString()
                    )
                    
                    StatisticItemView(
                        
                        title: NSLocalizedString("detail.statistics.total_volume", comment: ""),
                        value: (globalData.volumeUSD).toFormattedString()
                    )
                    
                    StatisticItemView(
                        
                        title: NSLocalizedString("detail.statistics.btc_dominance_short", comment: ""),
                        value: (globalData.btcDominance).toDominanceString()
                    )
                
                if let fearGreed = fearGreedData {
                    StatisticItemView(
                        title: fearGreed.valueClassification,
                        value: fearGreed.value
                    )
                }
                
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

// --- 2. "UPGRADED" HELPER VIEW ---
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
        // --- 3. SET A MINIMUM WIDTH TO EQUALIZE ---
        .frame(minWidth: 100) // Змушуємо всі картки бути "широкими"
        .padding(12)
        // --- 4. USE .ultraThinMaterial (Friend's suggestion) ---
        .background(.ultraThinMaterial) // "Затишне" розмиття
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
