//
//  SharedModelContainer.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 11.11.2025.
//


import Foundation
import SwiftData

// 1. We create a "wrapper" struct to hold our static container
struct SharedModelContainer {
    
    // 2. This is the code you just CUT from CoinTrackApp.swift
    static let sharedModelContainer: ModelContainer = {
        
        let schema = Schema([
            PortfolioEntity.self,
        ])
        
        let appGroupID = "group.com.Mixa88.CoinTrack"
        
        guard let groupContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            fatalError("Failed to get shared container URL.")
        }
        
        let storeURL = groupContainerURL.appendingPathComponent("CoinTrack.sqlite")
        let config = ModelConfiguration("CoinTrack", schema: schema, url: storeURL)

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create shared model container: \(error)")
        }
    }()
}
