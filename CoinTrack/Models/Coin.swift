//
//  Coin.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 06.11.2025.
//

import Foundation

struct Coin: Identifiable, Codable {
    
    let id: String
    let symbol: String
    let name: String
    let image: String
    let currentPrice: Double
    let priceChangePercentage24H: Double
    
   
    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case priceChangePercentage24H = "price_change_percentage_24h"
    }
    
    static var mock: Coin {
            Coin(
                id: "bitcoin",
                symbol: "btc",
                name: "Bitcoin",
                image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png?1696501400",
                currentPrice: 65123,
                priceChangePercentage24H: 1.25
            )
        }

        static var mock2: Coin {
            Coin(
                id: "ethereum",
                symbol: "eth",
                name: "Ethereum",
                image: "https://assets.coingecko.com/coins/images/279/large/ethereum.png?1696501638",
                currentPrice: 3456,
                priceChangePercentage24H: -0.5
            )
        }
}
