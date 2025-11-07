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
    
    init(coin: Coin) {
        self.coin = coin
        _viewModel = StateObject(wrappedValue: CoinDetailViewModel(coin: coin))
    }
    
    var body: some View {
        // --- 1. ADD ScrollView & main VStack ---
        ScrollView {
            VStack(spacing: 20) {
                
                // --- 2. Header Info (as before) ---
                Text(coin.name)
                    .font(.largeTitle)
                
                Text(coin.currentPrice.toCurrencyString())
                    .font(.title)
                
                // --- 3. The Chart (as before) ---
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 50)
                } else if viewModel.errorMessage != nil {
                    Text("Failed to load chart.")
                        .foregroundStyle(.red)
                        .padding(.top, 50)
                } else {
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
                    .frame(height: 250)
                    .padding(.top, 30)
                }
                
                // --- 4. NEW Statistics Card ---
                VStack(alignment: .leading, spacing: 12) {
                    Text("Statistics") // TODO: Localize
                        .font(.title3).bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                    
                    // We use our new "helper" view
                    StatisticRowView(title: "Market Cap", value: (coin.marketCap ?? 0).toCurrencyString())
                    StatisticRowView(title: "Market Cap Rank", value: "#\(coin.marketCapRank ?? 0)")
                    StatisticRowView(title: "24h High", value: (coin.high24H ?? 0).toCurrencyString())
                    StatisticRowView(title: "24h Low", value: (coin.low24H ?? 0).toCurrencyString())
                    StatisticRowView(title: "Total Volume", value: (coin.totalVolume ?? 0).toCurrencyString())
                }
                .padding()
                .background(Color(.systemGray6)) // Our "cozy card" style
                .cornerRadius(16)
                
                
                
                
                Spacer() // Pushes everything to the top
                
            } // --- End of main VStack
            .padding()
            
        } // --- End of ScrollView
        .navigationTitle(coin.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// --- 5. NEW Helper View for Statistics ---
// We put this here to keep our code clean, just like we did before.
struct StatisticRowView: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary) // "Cozy" gray
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
