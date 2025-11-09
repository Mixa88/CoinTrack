//
//  ContentView.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 06.11.2025.
//


import SwiftUI
import SwiftData

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
                    // --- 1. МИ ЗМІНЮЄМО ЛОГІКУ ТУТ ---
                                    // Ми більше не показуємо `List` і `ProgressView` одночасно.
                                    
                                    if viewModel.isLoading {
                                        // --- A. СТАН ЗАВАНТАЖЕННЯ: ПОКАЗУЄМО "СКЕЛЕТОНИ" ---
                                        List {
                                            ForEach(0..<15) { _ in // Покажемо 15 "рядків-заглушок"
                                                CoinRowSkeletonView()
                                                    .listRowSeparator(.hidden)
                                                    .listRowBackground(Color.clear)
                                            }
                                        }
                                        .listStyle(.plain)
                                        .transition(.opacity.animation(.easeIn(duration: 0.2))) // Плавна поява
                                    
                                    } else {
                                        // --- B. СТАН "ГОТОВО": ПОКАЗУЄМО РЕАЛЬНІ ДАНІ ---
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
                                            }
                                            .listRowSeparator(.hidden)
                                            .listRowBackground(Color.clear)
                                        }
                                        .listStyle(.plain)
                                        .refreshable {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            await viewModel.refreshAllData()
                                        }
                                        .transition(.opacity.animation(.easeOut(duration: 0.3))) // Плавне зникнення
                                    }
                                    
                                    // --- 3. ОВЕРЛЕЇ (ПОМИЛКА / ПОРОЖНЬО) ---
                                    // Вони, як і раніше, будуть поверх списку
                                    
                                    // Overlay: error message
                                    if let errorMessage = viewModel.errorMessage {
                                        // ... (твій код картки помилки з "Retry" залишається тут)
                                    }
                                    
                                    // Empty state for portfolio
                                    if !viewModel.isLoading && viewModel.selectedTab == .portfolio && viewModel.coins.isEmpty {
                                        // ... (твій код "Your portfolio is empty" залишається тут)
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

