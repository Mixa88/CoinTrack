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
    
    init(coin: Coin) {
        self.coin = coin
        _viewModel = StateObject(wrappedValue: CoinDetailViewModel(coin: coin))
    }
    
    // --- 1. THE "CLEAN" BODY ---
    // The main body is now simple and readable.
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // --- Header ---
                headerView
                
                // --- Loading / Error / Content ---
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 50)
                    
                } else if viewModel.errorMessage != nil {
                    Text("Failed to load data.")
                        .foregroundStyle(.red)
                        .padding(.top, 50)
                    
                } else {
                    // --- All our cards in one VStack ---
                    cardsView
                }
                
                Spacer()
                
            } // --- End of main VStack
            .padding()
            
        } // --- End of ScrollView
        .navigationTitle(coin.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// --- 2. WE BROKE THE UI INTO SMALL, "COZY" HELPERS ---

extension CoinDetailView {
    
    // --- Helper 1: The Header ---
    private var headerView: some View {
        VStack(spacing: 8) {
            Text(coin.name)
                .font(.largeTitle.bold())
            Text(coin.currentPrice.toCurrencyString())
                .font(.title2)
                .foregroundColor(.primary)
        }
        .padding(.top, 8)
    }
    
    // --- Helper 2: The Stack of Cards ---
    private var cardsView: some View {
        VStack(spacing: 20) {
            chartCard
            statisticsCard
            if viewModel.description != nil {
                descriptionCard
            }
        }
    }
    
    // --- Helper 3: Chart Card ---
    private var chartCard: some View {
        VStack(alignment: .leading) {
            Text("7-Day Chart")
                .font(.headline)
            Chart {
                ForEach(Array(viewModel.chartData.enumerated()), id: \.offset) { index, price in
                    LineMark(
                        x: .value("Date", index),
                        y: .value("Price", price)
                    )
                    .foregroundStyle(coin.priceChangePercentage24H ?? 0 >= 0 ? Color.green : Color.red)
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 60) // Your "sparkline" height
        }
        .asCard() // Use our custom card modifier
    }
    
    // --- Helper 4: Statistics Card ---
    private var statisticsCard: some View {
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
        .asCard() // Use our custom card modifier
    }
    
    // --- Helper 5: Description Card ---
    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About \(coin.name)")
                .font(.headline)
            
            Divider()
            
            Text(viewModel.description ?? "")
                .font(.subheadline)
                .foregroundStyle(.secondary)
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
                    .foregroundStyle(.blue) // Let's use system blue for links
                    .padding(.top, 4)
            }
        }
        .asCard() // Use our custom card modifier
    }
}

// --- 3. A "COZY" ViewModifier FOR OUR CARD STYLE ---
// (We can move this to a new file in Core/Extensions later)

// This modifier holds our "card" style
struct CardViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

extension View {
    // This makes it "cozy" to use
    func asCard() -> some View {
        self.modifier(CardViewModifier())
    }
}



// --- Preview ---
#Preview {
    NavigationStack {
        CoinDetailView(coin: Coin.mock)
    }
}
