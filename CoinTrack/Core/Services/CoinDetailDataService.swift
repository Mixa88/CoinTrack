//
//  CoinDetailDataService.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 06.11.2025.
//

import Foundation

class CoinDetailDataService {
    private let coinID: String
    private let apiBaseURL = "https://api.coingecko.com/api/v3/coins/"
    
    init(coinID: String) {
        self.coinID = coinID.lowercased() // <-- важно
        print("CoinDetailDataService initialized for \(coinID)")
    }
    
    func fetchChartData() async throws -> CoinDetail {
        let urlString = "\(apiBaseURL)\(coinID)/market_chart?vs_currency=usd&days=7"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? "no body"
            print("⚠️ Chart API error for \(coinID): \(httpResponse.statusCode) — \(body)")
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(CoinDetail.self, from: data)
    }
    
    func fetchCoinDescription() async throws -> CoinFullDetail? {
        let urlString = "\(apiBaseURL)\(coinID)?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? "no body"
            print("⚠️ Description API error for \(coinID): \(httpResponse.statusCode) — \(body)")
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(CoinFullDetail.self, from: data)
    }
}

