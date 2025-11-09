//
//  CoinDetailView.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 06.11.2025.
//

import SwiftUI
import Charts

struct CoinDetailView: View {
    let coin: Coin
    @StateObject private var viewModel: CoinDetailViewModel
    @State private var isDescriptionExpanded = false
    @State private var appear = false
    
    init(coin: Coin) {
        self.coin = coin
        _viewModel = StateObject(wrappedValue: CoinDetailViewModel(coin: coin))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                VStack(spacing: 8) {
                    Text(coin.name)
                        .font(.largeTitle.bold())
                    Text(coin.currentPrice.toCurrencyString())
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                .padding(.top, 8)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)
                .animation(.easeOut(duration: 0.5), value: appear)
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 50)
                    
                } else if viewModel.errorMessage != nil {
                    Text("Failed to load data.")
                        .foregroundStyle(.red)
                        .padding(.top, 50)
                    
                } else {
                    VStack(spacing: 20) {
                        
                        // 1. График
                        cardView {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("7-Day Chart")
                                    .font(.headline)
                                
                                ZStack {
                                    Chart {
                                        ForEach(Array(viewModel.chartData.enumerated()), id: \.offset) { index, price in
                                            LineMark(
                                                x: .value("Date", index),
                                                y: .value("Price", price)
                                            )
                                            .foregroundStyle(coin.priceChangePercentage24H >= 0 ? Color.green : Color.red)
                                        }
                                    }
                                    .chartXAxis(.hidden)
                                    .chartYAxis(.hidden)
                                    .frame(height: 80)
                                    
                                    // Градиент под графиком
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.green.opacity(0.2), .clear]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .frame(height: 80)
                                    .opacity(coin.priceChangePercentage24H >= 0 ? 1 : 0)
                                }
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: appear)
                        
                        // 2. Статистика
                        cardView {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Statistics")
                                    .font(.headline)
                                Divider()
                                StatisticRowView(title: "Market Cap", value: (coin.marketCap ?? 0).toFormattedString())
                                StatisticRowView(title: "Market Cap Rank", value: "#\(coin.marketCapRank ?? 0)")
                                StatisticRowView(title: "24h High", value: (coin.high24H ?? 0).toCurrencyString())
                                StatisticRowView(title: "24h Low", value: (coin.low24H ?? 0).toCurrencyString())
                                StatisticRowView(title: "Total Volume", value: (coin.totalVolume ?? 0).toFormattedString())
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeOut(duration: 0.5).delay(0.2), value: appear)
                        
                        // 3. About
                        if let description = viewModel.description {
                            cardView {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("About \(coin.name)")
                                        .font(.headline)
                                    
                                    Divider()
                                    
                                    Text(description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(isDescriptionExpanded ? nil : 3)
                                        .multilineTextAlignment(.leading)
                                        .animation(.easeInOut, value: isDescriptionExpanded)
                                    
                                    Button {
                                        withAnimation(.easeInOut) {
                                            isDescriptionExpanded.toggle()
                                        }
                                    } label: {
                                        Text(isDescriptionExpanded ? "Show Less" : "Read More")
                                            .font(.caption.bold())
                                            .foregroundColor(.blue)
                                            .padding(.top, 4)
                                    }
                                }
                            }
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .animation(.easeOut(duration: 0.5).delay(0.3), value: appear)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(coin.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            appear = true
        }
    }
}

// Универсальная карточка
private func cardView<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 10) {
        content()
    }
    .padding()
    .background(Color(.secondarySystemBackground))
    .cornerRadius(16)
    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
}

// Строка статистики
struct StatisticRowView: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    NavigationStack {
        CoinDetailView(coin: Coin.mock)
    }
}
