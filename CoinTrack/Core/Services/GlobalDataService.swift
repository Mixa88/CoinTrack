//
//  GlobalDataService.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 07.11.2025.
//

import Foundation

// This service is also a Singleton, just like CoinDataService.
// It fetches global market data.
class GlobalDataService {
    
    // 1. A single, shared instance
    static let shared = GlobalDataService()
    
    // 2. The URL for the /global endpoint
    private let apiURLString = "https://api.coingecko.com/api/v3/global"
    
    // 3. Private initializer
    private init() { }
    
    // 4. The main function our ViewModel will call
    func fetchGlobalData() async throws -> GlobalData? {
        
        guard let url = URL(string: apiURLString) else {
            throw URLError(.badURL)
        }
        
        // 5. Standard async network call
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // 6. Decode the JSON into our `GlobalDataResponse` "wrapper" struct
        let decoder = JSONDecoder()
        let globalDataResponse = try decoder.decode(GlobalDataResponse.self, from: data)
        
        // 7. Return the actual `data` object from the response
        return globalDataResponse.data
    }
}
