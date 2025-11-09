//
//  MainTabView.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 09.11.2025.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            
            // --- Tab 1: Our existing CoinList ---
            CoinListView()
                .tabItem {
                    Label("Prices", systemImage: "list.bullet") // TODO: Localize
                }
            
            // --- Tab 2: The new News tab ---
            NewsView()
                .tabItem {
                    Label("News", systemImage: "newspaper") // TODO: Localize
                }
        }
        // We can set the "cozy" tint color for the active tab here
        .tint(.blue)
    }
}

#Preview {
    MainTabView()
        // We MUST add this to the preview
        // so CoinListView (which needs SwiftData) doesn't crash it
        .modelContainer(for: PortfolioEntity.self, inMemory: true)
}
