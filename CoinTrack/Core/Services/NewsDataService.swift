//
//  NewsDataService.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 10.11.2025.
//

import Foundation

// This service is now pointed to CryptoCompare
class NewsDataService {
    
    static let shared = NewsDataService()
    
    // 1. --- THE NEW URL ---
    // This is the CryptoCompare /v2/news/ endpoint. No key needed.
    private let apiURLString = "https://min-api.cryptocompare.com/data/v2/news/?lang=EN"

    private init() { }
    
    func fetchNews() async throws -> [NewsArticle] {
        
        guard let url = URL(string: apiURLString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // 2. --- DECODE WITH THE NEW MODEL ---
        let decoder = JSONDecoder()
        let responseData = try decoder.decode(CryptoCompareResponse.self, from: data)
        
        // 3. Return the `Data` array
        return responseData.data
    }
}
