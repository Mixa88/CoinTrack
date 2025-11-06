//
//  ContentView.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 06.11.2025.
//

import SwiftUI

struct CoinListView: View {
    
    // 1. We create the "main brain" (ViewModel) for this screen.
    // @StateObject ensures it stays alive as long as the screen is visible.
    @StateObject private var viewModel = CoinListViewModel()
    
    var body: some View {
        NavigationStack {
            
            // 2. We use a ZStack to show a loading spinner *over* the list
            ZStack {
                
                // 3. The main list of coins
                List(viewModel.coins) { coin in
                    CoinRowView(coin: coin) // <-- Our "cozy" row!
                        .listRowSeparator(.hidden) // Makes it cleaner
                        .listRowBackground(Color.clear) // Transparent background
                }
                .listStyle(.plain)
                .refreshable {
                                await viewModel.refreshCoins() // Call our new function
                            }
                
                // 4. Show a loading spinner *only* when isLoading is true
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5) // Make it a bit bigger
                }
                
                // 5. Show an error message if one exists
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.headline)
                        .foregroundStyle(.red)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                }
            }
            .navigationTitle("Live Prices") // TODO: We can localize this later
            .searchable(text: $viewModel.searchText,
                        prompt: "Search by name or symbol...") // TODO: Localize
        }
    }
}

#Preview {
    CoinListView()
}
