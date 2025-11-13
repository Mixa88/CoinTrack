//
//  FearGreedResponse.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 13.11.2025.
//

import Foundation

// 1. This is the "wrapper" object the API returns
struct FearGreedResponse: Codable {
    // We only care about the 'data' array
    let data: [FearGreedData]
}

// 2. This is the actual data point
struct FearGreedData: Codable {
    
    // We only care about these two properties
    let value: String
    let valueClassification: String
    
    // 3. We use CodingKeys to translate "value_classification"
    // into our "cozy" `valueClassification`
    enum CodingKeys: String, CodingKey {
        case value
        case valueClassification = "value_classification"
    }
    
    // 4. Helper property to get the value as an Int
    var score: Int? {
        Int(value)
    }
}
