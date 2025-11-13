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
                
                // 1) Global stats
                if let globalData = viewModel.globalData {
                                    // Передаємо ОБИДВА об'єкти даних
                                    GlobalStatsView(globalData: globalData, fearGreedData: viewModel.fearGreedData)
                                }
                // 2) Segmented picker
                Picker("Select Tab", selection: $viewModel.selectedTab) {
                    Text("All Coins").tag(CoinListViewModel.ListTab.allCoins)
                    Text("Portfolio").tag(CoinListViewModel.ListTab.portfolio)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // 3) Main content area
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
                                    // --- Context Menu ---
                                    Button {
                                        viewModel.updatePortfolio(coin: coin)
                                    } label: {
                                        Label(viewModel.coinIsInPortfolio(coin: coin) ? "Remove from Portfolio" : "Add to Portfolio",
                                              systemImage: viewModel.coinIsInPortfolio(coin: coin) ? "star.slash.fill" : "star.fill")
                                    }
                                } preview: {
                                    // --- Context Menu Preview ---
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
                    
                    // --- THIS IS THE MISSING CODE FOR THE ERROR ---
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
                            .tint(Color("BrandGreen")) // Use our "cozy" green
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
                        .padding(.horizontal, 40)
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    // --- THIS IS THE MISSING CODE FOR THE EMPTY PORTFOLIO ---
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
                .animation(.default, value: viewModel.isLoading) // Animate the switch
                
            } // --- End of VStack
            .navigationTitle("Live Prices")
            .searchable(text: $viewModel.searchText, prompt: "Search by name or symbol...")
            .onAppear {
                viewModel.setup(modelContext: modelContext)
            }
        } // --- End of NavigationStack
    }
}

// MARK: - Preview
#Preview {
    CoinListView()
        .modelContainer(for: PortfolioEntity.self, inMemory: true)
}

