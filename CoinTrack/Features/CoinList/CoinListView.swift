//
//  ContentView.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 06.11.2025.
//


import SwiftUI
import SwiftData

struct CoinListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: CoinListViewModel
    
    // MARK: - Init
    init() {
        _viewModel = StateObject(wrappedValue: CoinListViewModel())
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                
                // --- 1. NEW: "COIN OF THE DAY" SPOTLIGHT ---
                // We show this card IF the spotlight coin exists
                if let coin = viewModel.spotlightCoin {
                    spotlightView(coin: coin)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                // --- 2. Global stats (as before) ---
                if let global = viewModel.globalData {
                    GlobalStatsView(globalData: global, fearGreedData: viewModel.fearGreedData)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .animation(.easeOut(duration: 0.28), value: (viewModel.globalData != nil))
                }
                
                // --- 3. Segmented picker (as before) ---
                Picker("Select Tab", selection: $viewModel.selectedTab) {
                    Text("All Coins").tag(CoinListViewModel.ListTab.allCoins)
                    Text("Portfolio").tag(CoinListViewModel.ListTab.portfolio)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // --- 4. Main content area (as before) ---
                ZStack {
                    
                    // --- A. LOADING STATE (SKELETONS) ---
                    if viewModel.isLoading {
                        List {
                            ForEach(0..<15) { _ in
                                CoinRowSkeletonView()
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                            }
                        }
                        .listStyle(.plain)
                        .transition(.opacity.animation(.easeIn(duration: 0.2)))
                    
                    // --- B. LOADED STATE (CONTENT) ---
                    } else {
                        List(viewModel.coins) { coin in
                            NavigationLink(destination: CoinDetailView(coin: coin)) {
                                HStack(spacing: 12) {
                                    CoinRowView(coin: coin)
                                    Spacer()
                                    Image(systemName: viewModel.coinIsInPortfolio(coin: coin) ? "star.fill" : "star")
                                        .font(.caption)
                                        .foregroundStyle(viewModel.coinIsInPortfolio(coin: coin) ? .yellow : .gray)
                                        .padding(8)
                                        .background(Circle().fill(Color(.systemGray6)))
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                                viewModel.updatePortfolio(coin: coin)
                                            }
                                        }
                                }
                                .padding(.vertical, 6)
                                .contextMenu {
                                    Button {
                                        viewModel.updatePortfolio(coin: coin)
                                    } label: {
                                        Label(viewModel.coinIsInPortfolio(coin: coin) ? "Remove from Portfolio" : "Add to Portfolio",
                                              systemImage: viewModel.coinIsInPortfolio(coin: coin) ? "star.slash.fill" : "star.fill")
                                    }
                                } preview: {
                                    CoinQuickStatsView(coin: coin)
                                }
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                        .listStyle(.plain)
                        .refreshable {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            await viewModel.refreshAllData()
                        }
                        .transition(.opacity.animation(.easeOut(duration: 0.3)))
                    }
                    
                    // --- C. OVERLAYS (Error / Empty) ---
                    
                    if let errorMessage = viewModel.errorMessage {
                        VStack(spacing: 12) {
                            Image(systemName: "wifi.slash")
                                .font(.system(size: 36))
                                .foregroundStyle(.gray)
                            Text("Something went wrong")
                                .font(.headline)
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                            
                            Button {
                                Task { await viewModel.refreshAllData() }
                            } label: {
                                Text("Retry")
                                    .fontWeight(.bold)
                            }
                            .buttonStyle(.bordered)
                            .tint(.blue) // Or your BrandGreen
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
                        .padding(.horizontal, 40)
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    if !viewModel.isLoading && viewModel.selectedTab == .portfolio && viewModel.coins.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "star")
                                .font(.system(size: 36))
                                .foregroundStyle(.gray)
                            Text("Your portfolio is empty")
                                .font(.headline)
                            Text("Tap the ⭐️ next to a coin to add it here.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .transition(.opacity)
                    }
                    
                } // --- End of ZStack
                .animation(.default, value: viewModel.isLoading)
                
            } // --- End of VStack
            .navigationTitle("Live Prices")
            .searchable(text: $viewModel.searchText, prompt: "Search by name or symbol...")
            .onAppear {
                viewModel.setup(modelContext: modelContext)
            }
            .task {
                // Fetch data when the view appears (ViewModel's init already handles this)
                // await viewModel.refreshAllData() // Це можна закоментувати, бо init вже працює
            }
            .padding(.top)
            .background(Color(.systemBackground).ignoresSafeArea())
        }
    }
    
    // --- 5. NEW: HELPER VIEW FOR THE SPOTLIGHT CARD ---
    @ViewBuilder
        private func spotlightView(coin: Coin) -> some View {
            
            // --- 1. ADD THIS LOGIC ---
            // Get the price change (or 0 if nil)
            let priceChange = coin.priceChangePercentage24H ?? 0
            
            // Determine the background color
            let bgColor: Color = {
                if priceChange > 0 {
                    return .green.opacity(0.1) // "Cozy" green
                } else if priceChange < 0 {
                    return .red.opacity(0.1)   // "Cozy" red
                } else {
                    return Color(.systemGray6) // Neutral gray
                }
            }()
            // --- END OF LOGIC ---

            VStack(alignment: .leading, spacing: 10) {
                // Header
                HStack {
                    Text("🔥 Coin of the Day")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    
                    Button {
                        withAnimation {
                            viewModel.spotlightCoin = nil
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                            .padding(8)
                            .background(Circle().fill(Color(.systemGray5)))
                    }
                }
                
                Divider()
                
                // The Coin Row
                NavigationLink(destination: CoinDetailView(coin: coin)) {
                    HStack(spacing: 12) {
                        CoinRowView(coin: coin)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
                .tint(.primary)
            }
            .padding()
            // --- 2. UPDATE THE BACKGROUND ---
            .background(bgColor) // <-- Use our new dynamic color
            .cornerRadius(16)
            .padding(.horizontal)
            // 3. Add a "cozy" animation when the color changes
            .animation(.easeInOut, value: bgColor)
        }
    }

// MARK: - Preview
#Preview {
    CoinListView()
        .modelContainer(for: PortfolioEntity.self, inMemory: true)
}

