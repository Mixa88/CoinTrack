//
//  MainTabView.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 09.11.2025.
//

import SwiftUI

struct MainTabView: View {
    
    @StateObject private var lockViewModel = AppLockViewModel()
    
    var body: some View {
        ZStack {
            
            TabView {
                CoinListView()
                    .tabItem {
                        Label("tab.prices", systemImage: "list.bullet")
                    }
                
                NewsView()
                    .tabItem {
                        Label("tab.news", systemImage: "newspaper") 
                    }
            }
            .tint(.blue)
            .contentShape(Rectangle())
            .allowsHitTesting(lockViewModel.isUnlocked)
            
            if !lockViewModel.isUnlocked {
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
