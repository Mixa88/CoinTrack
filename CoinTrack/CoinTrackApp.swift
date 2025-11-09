//
//  CoinTrackApp.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 06.11.2025.
//

import SwiftUI
import SwiftData

@main
struct CoinTrackApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: PortfolioEntity.self)
    }
}
