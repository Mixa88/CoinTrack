//
//  SpotlightService.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 13.11.2025.
//

import Foundation
import SwiftUI

// 1. This service manages which coin is "Coin of the Day"
// It uses UserDefaults (via @AppStorage) to remember the choice.
class SpotlightService {
    
    // 2. The key for saving the coin ID (e.g., "bitcoin")
    @AppStorage("spotlight_coin_id") private var spotlightCoinID: String?
    
    // 3. The key for saving the date it was last updated
    @AppStorage("spotlight_last_update") private var lastUpdateDate: TimeInterval?
    
    // 4. The main function our ViewModel will call
    @MainActor
    func getSpotlightCoin(from allCoins: [Coin]) -> Coin? {
        
        // 5. Check if we need to update the coin
        if shouldUpdateSpotlight() {
            // YES: Date is old. Pick a new coin.
            guard let newSpotlightCoin = allCoins.randomElement() else {
                return nil // No coins to pick from
            }
            
            // Save the new coin's ID and the current date
            self.spotlightCoinID = newSpotlightCoin.id
            self.lastUpdateDate = Date().timeIntervalSince1970
            print("Spotlight: New coin of the day selected: \(newSpotlightCoin.name)")
            return newSpotlightCoin
            
        } else {
            // NO: Date is still "today". Find the *saved* coin.
            guard let savedID = spotlightCoinID else {
                // This should rarely happen, but just in case
                return allCoins.randomElement()
            }
            
            print("Spotlight: Returning saved coin of the day.")
            // Find the coin in the main list that matches our saved ID
            return allCoins.first(where: { $0.id == savedID })
        }
    }
    
    // 6. Helper function to check the date
    private func shouldUpdateSpotlight() -> Bool {
        guard let lastUpdate = lastUpdateDate else {
            // If we've *never* saved a date, we MUST update
            return true
        }
        
        let lastUpdateDay = Calendar.current.startOfDay(for: Date(timeIntervalSince1970: lastUpdate))
        let today = Calendar.current.startOfDay(for: Date())
        
        // If the last update day is *before* today, we MUST update
        return lastUpdateDay < today
    }
}
