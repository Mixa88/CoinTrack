//
//  CoinDataService.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 06.11.2025.
//


import Foundation

// This service is a "Singleton" - a single instance that the whole app can share.
// It's responsible for ONE thing: fetching data from the API.
class CoinDataService {
    
    // 1. We create a single, shared instance of this service.
    static let shared = CoinDataService()
    
    // 2. The URL string for the CoinGecko API
    // This fetches the top 100 coins, in USD, ordered by market cap.
    private let apiURLString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false"
    
    // 3. Make the initializer private so no one else can create an instance.
    private init() { }
    
    // 4. This is the main function our ViewModel will call.
    // It's `async` (it runs in the background) and `throws` (it can fail).
    func fetchCoins() async throws -> [Coin] {

        guard let url = URL(string: apiURLString) else {
            throw URLError(.badURL)
        }

        // Create a URLRequest
        var request = URLRequest(url: url)
        // Set the User-Agent header
        request.setValue("CoinTrackApp/1.0 (Contact: mixa.mixastep@gmail.com)", forHTTPHeaderField: "User-Agent")
       

        // Use the request, not the url
        let (data, response) = try await URLSession.shared.data(for: request) // <-- CHANGED

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        let coins = try decoder.decode([Coin].self, from: data)

        return coins
    }
}
