//
//  GlobalData.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 07.11.2025.
//

import Foundation

// 1. This struct holds the response from the /global endpoint
struct GlobalDataResponse: Codable {
    let data: GlobalData?
}

// 2. This struct holds the actual statistics
struct GlobalData: Codable {
    
    // We will get a dictionary like: {"usd": 12345, "eur": 67890}
    // We only care about "usd"
    let totalMarketCap: [String: Double]
    let totalVolume: [String: Double]
    let marketCapPercentage: [String: Double]
    
    // 3. We use CodingKeys to match the API's naming
    enum CodingKeys: String, CodingKey {
        case totalMarketCap = "total_market_cap"
        case totalVolume = "total_volume"
        case marketCapPercentage = "market_cap_percentage"
    }
    
    // --- 4. Helper properties (Computed Properties) ---
    // These make it "cozy" to access the data.
    
    /// Returns the Total Market Cap in USD
    var marketCapUSD: Double {
        return totalMarketCap["usd"] ?? 0
    }
    
    /// Returns the Total Volume in USD
    var volumeUSD: Double {
        return totalVolume["usd"] ?? 0
    }
    
    /// Returns the dominance of Bitcoin (BTC)
    var btcDominance: Double {
        return marketCapPercentage["btc"] ?? 0
    }
}
