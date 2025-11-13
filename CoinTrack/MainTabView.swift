//
//  MainTabView.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 09.11.2025.
//

import SwiftUI

struct MainTabView: View {
    
    // 1. Create the "gatekeeper" ViewModel
    // We use @StateObject because this View "owns" it.
    @StateObject private var lockViewModel = AppLockViewModel()
    
    var body: some View {
        // 2. We wrap everything in a ZStack
        ZStack {
            
            // 3. The "Content" (our app)
            // It's ALWAYS in the hierarchy, but...
            TabView {
                CoinListView()
                    .tabItem {
                        Label("Prices", systemImage: "list.bullet")
                    }
                
                NewsView()
                    .tabItem {
                        Label("News", systemImage: "newspaper")
                    }
            }
            .tint(.blue)
            
            // 4. The "Gate"
            // If we are NOT unlocked...
            if !lockViewModel.isUnlocked {
                // ...show the LockView ON TOP of everything.
                LockView(viewModel: lockViewModel)
                    .transition(.opacity.animation(.easeIn(duration: 0.3)))
            }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: PortfolioEntity.self, inMemory: true)
}
