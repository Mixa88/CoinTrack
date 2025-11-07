//
//  PortfolioDataService.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 07.11.2025.
//

import Foundation
import SwiftData

// This service is NOT a singleton.
// It needs the @ModelContext (the "database connection")
// which is passed down from the View.
@MainActor
class PortfolioDataService {
    
    // 1. The "database connection"
    private var modelContext: ModelContext
    
    // 2. The local list of saved IDs
    @Published var savedEntities: [PortfolioEntity] = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        // 3. Immediately load all saved data
        fetchPortfolio()
    }
    
    // 4. READ
    func fetchPortfolio() {
        do {
            // "Fetch all items of type PortfolioEntity"
            let descriptor = FetchDescriptor<PortfolioEntity>()
            self.savedEntities = try modelContext.fetch(descriptor)
            print("SwiftData: Successfully fetched portfolio. Count: \(savedEntities.count)")
        } catch {
            print("SwiftData: Error fetching portfolio. \(error)")
        }
    }
    
    // 5. CREATE
    func addCoin(coinID: String) {
        // "Create a new entity and insert it"
        let entity = PortfolioEntity(coinID: coinID)
        modelContext.insert(entity)
        save() // We must explicitly save
    }
    
    // 6. DELETE
    func removeCoin(coinID: String) {
        // "Find the specific entity and delete it"
        if let entity = savedEntities.first(where: { $0.coinID == coinID }) {
            modelContext.delete(entity)
            save()
        }
    }
    
    // 7. SAVE (Helper function)
    private func save() {
        do {
            // "Try to commit the changes to disk"
            try modelContext.save()
            // After saving, reload our local list
            fetchPortfolio()
        } catch {
            print("SwiftData: Error saving. \(error)")
        }
    }
}
