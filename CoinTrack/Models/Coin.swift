//
//  Coin.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 06.11.2025.
//

import Foundation

struct Coin: Identifiable, Codable, Equatable {
    
    let id: String
    let symbol: String
    let name: String
    let image: String
    let currentPrice: Double
    let priceChangePercentage24H: Double?
    
    let marketCap: Double?
        let marketCapRank: Int?
        let totalVolume: Double?
        let high24H: Double?
        let low24H: Double?
    
   
    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case priceChangePercentage24H = "price_change_percentage_24h"
        
        case marketCap = "market_cap"
                case marketCapRank = "market_cap_rank"
                case totalVolume = "total_volume"
                case high24H = "high_24h"
                case low24H = "low_24h"
    }
    
    static var mock: Coin {
        Coin(
                    id: "bitcoin",
                    symbol: "btc",
                    name: "Bitcoin",
                    image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png?1696501400",
                    currentPrice: 65123,
                    priceChangePercentage24H: 1.25,
                    marketCap: 1200000000000,
                    marketCapRank: 1,
                    totalVolume: 50000000000,
                    high24H: 66000,
                    low24H: 64000
                )
        }

        static var mock2: Coin {
            Coin(
                        id: "ethereum",
                        symbol: "eth",
                        name: "Ethereum",
                        image: "https://assets.coingecko.com/coins/images/279/large/ethereum.png?1696501638",
                        currentPrice: 3456,
                        priceChangePercentage24H: -0.5,
                        marketCap: 400000000000,
                        marketCapRank: 2,
                        totalVolume: 20000000000,
                        high24H: 3500,
                        low24H: 3400
                    )
        }
}
