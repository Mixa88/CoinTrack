//
//  CoinDetailDataService.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 06.11.2025.
//

import Foundation

// This service is NOT a singleton.
// We will create a new instance of it for EACH CoinDetailView.
// This is because it needs a specific coinID to fetch data.
class CoinDetailDataService {
    
    // 1. A variable to hold the coinID (e.g., "bitcoin")
    private let coinID: String
    private let apiBaseURL = "https://api.coingecko.com/api/v3/coins/"
    
    // 2. The initializer receives the coinID
    init(coinID: String) {
        self.coinID = coinID
        print("CoinDetailDataService initialized for \(coinID)")
    }
    
    // 3. The function to fetch the 7-day chart data
    func fetchChartData() async throws -> CoinDetail {
        
        // 4. We build the URL, e.g.,
        // "https://api.coingecko.com/api/v3/coins/bitcoin/market_chart?vs_currency=usd&days=7"
        let urlString = "\(apiBaseURL)\(coinID)/market_chart?vs_currency=usd&days=7"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        // 5. Standard async network call
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // 6. Decode the JSON into our `CoinDetail` struct
        let decoder = JSONDecoder()
        let coinDetail = try decoder.decode(CoinDetail.self, from: data)
        
        return coinDetail
    }
}
