//
//  FearGreedDataService.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 13.11.2025.
//

import Foundation

// This service is also a Singleton.
// It fetches the Fear & Greed Index.
class FearGreedDataService {
    
    // 1. A single, shared instance
    static let shared = FearGreedDataService()
    
    // 2. The URL for the /fng endpoint (limit=1 gets only the latest value)
    private let apiURLString = "https://api.alternative.me/fng/?limit=1"
    
    // 3. Private initializer
    private init() { }
    
    // 4. The main fetch function
    func fetchFearGreedIndex() async throws -> FearGreedData? {
        
        guard let url = URL(string: apiURLString) else {
            throw URLError(.badURL)
        }
        
        // 5. Standard async network call
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // 6. Decode the JSON into our `FearGreedResponse`
        let decoder = JSONDecoder()
        let responseData = try decoder.decode(FearGreedResponse.self, from: data)
        
        // 7. Return the *first* item from the 'data' array
        return responseData.data.first
    }
}
