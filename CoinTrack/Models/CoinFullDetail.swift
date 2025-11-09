//
//  CoinFullDetail.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 07.11.2025.
//

import Foundation

// 1. This struct holds the massive JSON response
// from the /coins/{id} endpoint
struct CoinFullDetail: Codable {
    // 2. We only care about this ONE property
    let description: CoinDescription?
}

// 3. This struct holds the nested description
// which is a dictionary of languages
struct CoinDescription: Codable {
    // We only care about the English ("en") description
    let en: String?
    
    // 4. Helper to "cozily" get the text
    var englishDescription: String {
        return en ?? "No description available." // TODO: Localize
    }
}
