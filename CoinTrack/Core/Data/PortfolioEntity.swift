//
//  PortfolioEntity.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 07.11.2025.
//

import Foundation
import SwiftData

// 1. @Model is the "magic" macro that turns this class
// into a model that SwiftData can save.
@Model
class PortfolioEntity {
    
    // 2. This is the coin ID, e.g., "bitcoin"
    let coinID: String
    
    // 3. It's good practice to save when it was added
    let savedAt: Date
    
    // 4. The initializer
    init(coinID: String) {
        self.coinID = coinID
        self.savedAt = Date()
    }
}
