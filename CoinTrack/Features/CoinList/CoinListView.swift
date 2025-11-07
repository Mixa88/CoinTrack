//
//  ContentView.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 06.11.2025.
//


import SwiftUI
import SwiftData

struct CoinListView: View {
    
    // "Catch" the database connection from the environment
    @Environment(\.modelContext) private var modelContext
    
    // We create the ViewModel using a custom initializer
    // to pass the modelContext correctly.
    @StateObject private var viewModel: CoinListViewModel
    
    // Custom Initializer
    // This is the "clean" way to pass the modelContext
    // into our ViewModel *before* the View appears.
    init() {
        // This temporary context setup is for the init() scope.
        // The real context will be injected via .onAppear
        // but this satisfies the init() requirement.
        // NOTE: This is a common pattern, but we'll use .onAppear to pass the *real* context.
        // Let's correct the pattern we used before.
        
        // This is the correct way we finished with:
        _viewModel = StateObject(wrappedValue: CoinListViewModel())
    }
    
    var body: some View {
        NavigationStack {
            
            VStack { // We wrap everything in a VStack to hold the Picker
                
                // --- 1. THE PICKER (All Coins / Portfolio) ---
                Picker("Select Tab", selection: $viewModel.selectedTab) {
                    Text("All Coins").tag(CoinListViewModel.ListTab.allCoins)
                    Text("Portfolio").tag(CoinListViewModel.ListTab.portfolio)
                }
                .pickerStyle(.segmented) // "Cozy" segmented style
                .padding(.horizontal)
                
                // --- 2. ZStack for Loading/Content ---
                ZStack {
                    
                    // --- 3. The main list of coins ---
                    List(viewModel.coins) { coin in
                        NavigationLink(destination: CoinDetailView(coin: coin)) {
                            
                            // --- We build the row "inline" here ---
                            HStack {
                                // Our "dumb" row
                                CoinRowView(coin: coin)
                                
                                // --- The Star Button ---
                                Image(systemName: viewModel.coinIsInPortfolio(coin: coin) ? "star.fill" : "star")
                                    .font(.caption)
                                    .foregroundStyle(viewModel.coinIsInPortfolio(coin: coin) ? .yellow : .gray)
                                    .padding(8)
                                    .background(Circle().fill(Color(.systemGray6)))
                                    .onTapGesture {
                                        // Call the ViewModel
                                        viewModel.updatePortfolio(coin: coin)
                                    }
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await viewModel.refreshCoins() // Pull-to-refresh
                    }
                    
                    // --- 4. Show a loading spinner ---
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                    }
                    
                    // --- 5. Show an error message ---
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.headline)
                            .foregroundStyle(.red)
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(16)
                    }
                    
                    // --- 6. Show empty state for Portfolio ---
                    if !viewModel.isLoading && viewModel.selectedTab == .portfolio && viewModel.coins.isEmpty {
                        Text("Your portfolio is empty.\nTap the ⭐️ to add coins!")
                            .font(.headline)
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                } // --- End of ZStack
                
            } // --- End of VStack
            .navigationTitle("Live Prices")
            .searchable(text: $viewModel.searchText,
                        prompt: "Search by name or symbol...")
            .onAppear {
                // --- THIS IS THE FIX ---
                // When the View appears, modelContext is ready.
                // We call our setup() function and pass it.
                viewModel.setup(modelContext: modelContext)
            }
        }
    }
}

// --- PREVIEW ---
#Preview {
    CoinListView()
        // We add the modelContainer to the Preview so it doesn't crash
        .modelContainer(for: PortfolioEntity.self, inMemory: true)
}
