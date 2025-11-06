//
//  CoinDetailView.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 06.11.2025.
//


import SwiftUI
import Charts 

struct CoinDetailView: View {
    
    // 2. We are "passing in" the basic coin info
    let coin: Coin
    
    // 3. We "create" the brain for this screen
    // We make it `private` because this View "owns" this ViewModel.
    @StateObject private var viewModel: CoinDetailViewModel
    
    // 4. We need a custom initializer to pass the `coin`
    // from this View to the ViewModel's initializer.
    init(coin: Coin) {
        self.coin = coin
        _viewModel = StateObject(wrappedValue: CoinDetailViewModel(coin: coin))
    }
    
    var body: some View {
        VStack {
            // --- 5. Header Info (we already have this) ---
            Text(coin.name)
                .font(.largeTitle)
            
            Text(coin.currentPrice.toCurrencyString())
                .font(.title)
            
            // --- 6. The Chart ---
            if viewModel.isLoading {
                ProgressView()
                    .padding(.top, 50)
            } else if viewModel.errorMessage != nil {
                Text("Failed to load chart.") // TODO: Localize
                    .foregroundStyle(.red)
                    .padding(.top, 50)
            } else {
                
                // --- THIS IS THE MAGIC ---
                Chart {
                    // 7. Loop over our chartData
                    ForEach(Array(viewModel.chartData.enumerated()), id: \.offset) { index, price in
                        
                        // 8. Create a LineMark
                        LineMark(
                            x: .value("Date", index),
                            y: .value("Price", price)
                        )
                        .foregroundStyle(coin.priceChangePercentage24H >= 0 ? Color.green : Color.red)
                    }
                }
                .chartXAxis(.hidden) // Hide the X-axis labels (days)
                .chartYAxis(.hidden) // Hide the Y-axis labels (price)
                .frame(height: 250) // Give the chart a nice height
                .padding(.top, 30)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle(coin.name)
        .navigationBarTitleDisplayMode(.inline) // Make the title smaller
    }
}

#Preview {
    // We must use a NavigationStack in the preview
    // to see the navigationTitle
    NavigationStack {
        CoinDetailView(coin: Coin.mock)
    }
}
