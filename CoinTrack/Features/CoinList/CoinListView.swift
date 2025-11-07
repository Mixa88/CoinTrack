//
//  ContentView.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 06.11.2025.
//

// CoinListView.swift
import SwiftUI
import SwiftData

struct CoinListView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    // 1. We go back to a simple @StateObject initialization
    @StateObject private var viewModel = CoinListViewModel()
    
    // 2. NO custom init() needed! The error is gone.
    
    var body: some View {
        NavigationStack {
            ZStack {
                // ... (List, ProgressView, etc. are all the same) ...
                List(viewModel.coins) { coin in
                    NavigationLink(destination: CoinDetailView(coin: coin)) {
                        CoinRowView(coin: coin)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.refreshCoins()
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.headline)
                        .foregroundStyle(.red)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                }
            }
            .navigationTitle("Live Prices")
            .searchable(text: $viewModel.searchText,
                        prompt: "Search by name or symbol...")
            // 3. --- THIS IS THE FIX ---
            // When the View appears, modelContext is ready.
            // We call our setup() function and pass it.
            .onAppear {
                viewModel.setup(modelContext: modelContext)
            }
        }
    }
}

#Preview {
    CoinListView()
        .modelContainer(for: PortfolioEntity.self, inMemory: true)
}
