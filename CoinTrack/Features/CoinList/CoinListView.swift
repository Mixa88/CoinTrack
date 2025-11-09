//
//  ContentView.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 06.11.2025.
//


import SwiftUI
import SwiftData

/// CoinListView — обновлённая, совместимая версия под твою структуру MVVM + SwiftData.
/// Ожидается, что в проекте есть:
/// - Coin (Identifiable)
/// - CoinListViewModel (как в твоём коде)
/// - GlobalStatsView
/// - CoinRowView
/// - CoinDetailView
/// - PortfolioEntity (для preview)
struct CoinListView: View {
    
    // modelContext приходит из окружения (SwiftData)
    @Environment(\.modelContext) private var modelContext
    
    // ViewModel создаём в init и передаём реальный modelContext в onAppear
    @StateObject private var viewModel: CoinListViewModel
    
    // MARK: - Init
    init() {
        _viewModel = StateObject(wrappedValue: CoinListViewModel())
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                
                // 1) Global stats (если есть)
                if let global = viewModel.globalData {
                    GlobalStatsView(data: global)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        // FIX: animation value must be Equatable — use Bool (non-nil) instead of Optional<GlobalData>
                        .animation(.easeOut(duration: 0.28), value: (viewModel.globalData != nil))
                }
                
                // 2) Segmented picker (All Coins / Portfolio)
                Picker("", selection: $viewModel.selectedTab) {
                    Text("All Coins").tag(CoinListViewModel.ListTab.allCoins)
                    Text("Portfolio").tag(CoinListViewModel.ListTab.portfolio)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // 3) Main content area: list + overlayed loading / error / empty states
                ZStack {
                    // Main list (only when not loading and no fatal error)
                    List {
                        ForEach(viewModel.coins) { coin in
                            NavigationLink(destination: CoinDetailView(coin: coin)) {
                                HStack(spacing: 12) {
                                    // left: coin row
                                    CoinRowView(coin: coin)
                                    
                                    Spacer()
                                    
                                    // right: star button for portfolio
                                    Image(systemName: viewModel.coinIsInPortfolio(coin: coin) ? "star.fill" : "star")
                                        .font(.caption)
                                        .foregroundStyle(viewModel.coinIsInPortfolio(coin: coin) ? .yellow : .gray)
                                        .padding(8)
                                        .background(Circle().fill(Color(.systemGray6)))
                                        .onTapGesture {
                                            // call VM to add/remove
                                            // Add a tiny animation for feedback
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                                viewModel.updatePortfolio(coin: coin)
                                            }
                                        }
                                }
                                .padding(.vertical, 6)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .refreshable {
                        
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        
                        // Pull-to-refresh calls VM's async refresh
                        await viewModel.refreshAllData()
                    }
                    
                    // Overlay: loading indicator
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.2)
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .transition(.opacity)
                    }
                    
                    // Overlay: error message (if any)
                    if let errorMessage = viewModel.errorMessage {
                        VStack(spacing: 12) {
                            Text("Something went wrong")
                                .font(.headline)
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                            Button {
                                Task { await viewModel.refreshAllData() }
                            } label: {
                                Text("Retry")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                            .frame(maxWidth: 160)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
                        .padding(.horizontal, 40)
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Empty state for portfolio
                    if !viewModel.isLoading && viewModel.selectedTab == .portfolio && viewModel.coins.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "star")
                                .font(.system(size: 36))
                                .foregroundStyle(.gray)
                            Text("Your portfolio is empty")
                                .font(.headline)
                            Text("Tap the ⭐️ next to a coin to add it here.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .transition(.opacity)
                    }
                } // ZStack
            } // VStack
            .navigationTitle("Live Prices")
            .searchable(text: $viewModel.searchText, prompt: "Search by name or symbol...")
            .onAppear {
                // Pass the real modelContext to the ViewModel (only once)
                viewModel.setup(modelContext: modelContext)
            }
            .task {
                // initial fetch (ViewModel already starts fetch in init in your code,
                // but it's safe to call refresh here to ensure latest data when view appears)
                await viewModel.refreshAllData()
            }
            .padding(.top)
            .background(Color(.systemBackground).ignoresSafeArea()) // keep background consistent
        } // NavigationStack
    }
}

// MARK: - Preview
#Preview {
    CoinListView()
        .modelContainer(for: PortfolioEntity.self, inMemory: true)
}

