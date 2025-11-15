//
//  NewsArticle.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 15.11.2025.
//

import Foundation

// 1. "Wrapper" for the CryptoCompare API response
struct CryptoCompareResponse: Codable {
    let data: [NewsArticle]
    
    // We use CodingKeys because the API sends "Data" (uppercase)
    enum CodingKeys: String, CodingKey {
        case data = "Data"
    }
}

// 2. The new NewsArticle model
struct NewsArticle: Codable, Identifiable {
    let id: String
    let title: String
    let url: String
    let source: String // API provides "source" as a simple string
    let imageUrl: String
    
    // 3. CodingKeys to match the API
    enum CodingKeys: String, CodingKey {
        case id, title, url, source
        case imageUrl = "imageurl"
    }
    
    // 4. Helper for the URL
    var articleURL: URL? {
        return URL(string: url)
    }
}
