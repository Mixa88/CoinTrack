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
                
                // --- 1. "COIN OF THE DAY" SPOTLIGHT ---
                if let coin = viewModel.spotlightCoin {
                    spotlightView(coin: coin)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                // --- 2. Global stats ---
                if let global = viewModel.globalData {
                    GlobalStatsView(globalData: global, fearGreedData: viewModel.fearGreedData)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .animation(.easeOut(duration: 0.28), value: (viewModel.globalData != nil))
                }
                
                // --- 3. Segmented picker ---
                Picker("Select Tab", selection: $viewModel.selectedTab) {
                    
                    Text("prices.tab.all_coins").tag(CoinListViewModel.ListTab.allCoins)
                    Text("prices.tab.portfolio").tag(CoinListViewModel.ListTab.portfolio)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // --- 4. Main content area ---
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
                                        // 💡 ИЗМЕНЕНО: Динамический выбор ключа для Label
                                        let labelKey = viewModel.coinIsInPortfolio(coin: coin) ? "prices.context.remove" : "prices.context.add"
                                        let systemImage = viewModel.coinIsInPortfolio(coin: coin) ? "star.slash.fill" : "star.fill"
                                        
                                        Label(labelKey, systemImage: systemImage)
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
                            
                            
                            Text("prices.error.title")
                                .font(.headline)
                            
                            Text(errorMessage) // Это OK, это динамическая ошибка
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                            
                            Button {
                                Task { await viewModel.retryRefresh() }
                            } label: {
                                
                                if viewModel.isRetrying {
                                    ProgressView()
                                        .frame(height: 20)
                                } else {
                                    Text("common.retry")
                                        .fontWeight(.bold)
                                }
                            }
                            // ✅ ИСПРАВЛЕНО: Модификаторы ПЕРЕМЕЩЕНЫ сюда (применяются к Button)
                            .buttonStyle(.bordered)
                            .tint(.blue)
                            .disabled(viewModel.isRetrying)
                            
                        } // <-- 'VStack' закрылся
                        // ✅ ИСПРАВЛЕНО: Модификаторы ПЕРЕМЕЩЕНЫ сюда (применяются к VStack)
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
                            
                            // 💡 ИЗМЕНЕНО: Заменен "Your portfolio is empty" на ключ
                            Text("prices.empty_portfolio.title")
                                .font(.headline)
                            
                            // 💡 ИЗМЕНЕНО: Заменен субтитр на ключ
                            Text("prices.empty_portfolio.subtitle")
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
            
            // 💡 ИЗМЕНЕНО: Заменен "Live Prices" на ключ
            .navigationTitle("prices.title")
            
            // 💡 ИЗМЕНЕНО: Заменен prompt на ключ (требует Text())
            .searchable(text: $viewModel.searchText, prompt: Text("common.search.prompt"))
            
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
        
    } // ✅ ИСПРАВЛЕНО: Добавлена скобка для 'var body'
    
    // --- 5. HELPER VIEW FOR THE SPOTLIGHT CARD ---
    @ViewBuilder
    private func spotlightView(coin: Coin) -> some View {
        
        
        let priceChange = coin.priceChangePercentage24H ?? 0
        let bgColor: Color = {
            if priceChange > 0 {
                return .green.opacity(0.1) // "Cozy" green
            } else if priceChange < 0 {
                return .red.opacity(0.1)   // "Cozy" red
            } else {
                return Color(.systemGray6) // Neutral gray
            }
        }()
        
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                
                Text("prices.spotlight.title")
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
                // 💡 ДОБАВЛЕНО: accessibilityLabel для кнопки "X"
                .accessibilityLabel("prices.spotlight.dismiss")
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
        .background(bgColor)
        .cornerRadius(16)
        .padding(.horizontal)
        .animation(.easeInOut, value: bgColor)
    }
}

// MARK: - Preview
#Preview {
    CoinListView()
        .modelContainer(for: PortfolioEntity.self, inMemory: true)
}
