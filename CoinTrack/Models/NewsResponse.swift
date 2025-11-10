//
//  NewsResponse.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 10.11.2025.
//

import Foundation

// 1. The "wrapper" object that the API returns
struct NewsResponse: Codable {
    let results: [NewsArticle]
}

struct NewsArticle: Codable, Identifiable {
    let id: Int
    let title: String?       // <-- ADD ? (Title might be null)
    let url: String?         // <-- ADD ? (URL might be null)
    let source: NewsSource?  // <-- ADD ? (Source might be null)
    
    // 3. Helper to safely unwrap the optional URL
    var articleURL: URL? {
        guard let url = url else { return nil } // Safely unwrap
        return URL(string: url)
    }
}

// 4. The nested struct for the news source
struct NewsSource: Codable {
    let title: String?
    let domain: String?
    let url: String?
}
