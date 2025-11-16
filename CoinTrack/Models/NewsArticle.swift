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
    
    enum CodingKeys: String, CodingKey {
        case data = "Data"
    }
}

// 2. The new "Armored" NewsArticle model (from your friend)
struct NewsArticle: Codable, Identifiable {
    let id: String
    let title: String
    let url: String
    let source: String
    let imageUrl: String?       // Optional
    let publishedOn: TimeInterval? // Optional

    enum CodingKeys: String, CodingKey {
        case id, title, url, source
        case imageUrl = "imageurl"
        case publishedOn = "published_on"
    }

    // "Armored" Decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Handle id being Int or String
        if let intId = try? container.decode(Int.self, forKey: .id) {
            self.id = String(intId)
        } else if let stringId = try? container.decode(String.self, forKey: .id) {
            self.id = stringId
        } else {
            // Fallback just in case, to conform to Identifiable
            self.id = UUID().uuidString
        }

        // Safely decode all other properties, providing defaults
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? "No Title Provided"
        self.url = try container.decodeIfPresent(String.self, forKey: .url) ?? ""
        self.source = try container.decodeIfPresent(String.self, forKey: .source) ?? "Unknown Source"
        
        let rawUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        self.imageUrl = rawUrl?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.publishedOn = try container.decodeIfPresent(TimeInterval.self, forKey: .publishedOn)
    }

    // Helper for the article link
    var articleURL: URL? {
        URL(string: url)
    }

    // "Smart" Image URL helper
    var fullImageURL: URL? {
        guard let imageUrl = imageUrl, !imageUrl.isEmpty else { return nil }

        if imageUrl.hasPrefix("http://") || imageUrl.hasPrefix("https://") {
            return URL(string: imageUrl)
        }
        
        // Handle "//" prefix (schemeless URL)
        if imageUrl.hasPrefix("//") {
             return URL(string: "https:\(imageUrl)")
        }

        // Handle relative path
        return URL(string: "https://www.cryptocompare.com\(imageUrl)")
    }
}
