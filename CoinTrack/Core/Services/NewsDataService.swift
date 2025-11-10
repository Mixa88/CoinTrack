//
//  NewsDataService.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 10.11.2025.
//

import Foundation

// This service will be a singleton, just like our others
class NewsDataService {
    
    // 1. A single, shared instance
    static let shared = NewsDataService()
    
    // 2. Build the URL using our secure key from Secrets.swift
    // We also add "public=true" to get general news
    private let apiURLString = "https://cryptopanic.com/api/developer/v2/posts/?auth_token=\(Secrets.cryptoPanicAPIKey)&public=true"

    // 3. Private initializer
    private init() { }
    
    // 4. The main fetch function
    func fetchNews() async throws -> [NewsArticle] {
        
        guard let url = URL(string: apiURLString) else {
            throw URLError(.badURL)
        }
        
        // 5. Standard async network call
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // 6. Decode the JSON into our `NewsResponse`
        let decoder = JSONDecoder()
        let newsResponse = try decoder.decode(NewsResponse.self, from: data)
        
        // 7. Return the `results` array
        return newsResponse.results
    }
}
