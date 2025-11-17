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
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                headerView
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 50)
                    
                } else if viewModel.errorMessage != nil {
                    Text("news.error.title")
                        .foregroundStyle(.red)
                        .padding(.top, 50)
                    
                } else {
                    cardsView
                }
                
                Spacer()
                
            }
            .padding()
            
        }
        .navigationTitle(coin.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension CoinDetailView {
    
    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 8) {
            Text(coin.name)
                .font(.largeTitle.bold())
            Text(coin.currentPrice.toCurrencyString())
                .font(.title2)
                .foregroundColor(.primary)
                .contentTransition(.numericText())
        }
        .padding(.top, 8)
    }
    
    // MARK: - Cards Stack
    private var cardsView: some View {
        VStack(spacing: 20) {
            chartCard
            statisticsCard
            if viewModel.description != nil {
                descriptionCard
            }
        }
    }
    
    // MARK: - Chart Card
    private var chartCard: some View {
        VStack(alignment: .leading) {
            Text("detail.chart.title")
                .font(.headline)
            
            Chart {
                ForEach(Array(viewModel.chartData.enumerated()), id: \.offset) { index, price in
                    
                    LineMark(
                        x: .value("Date", index),
                        y: .value("Price", price)
                    )
                    .lineStyle(.init(lineWidth: 2))
                    .foregroundStyle(coin.priceChangePercentage24H ?? 0 >= 0 ? Color.green : Color.red)
                    
                    AreaMark(
                        x: .value("Date", index),
                        y: .value("Price", price)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                (coin.priceChangePercentage24H ?? 0 >= 0 ? Color.green : Color.red).opacity(0.3),
                                .clear
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 60)
        }
        .asCard()
    }
    
    // MARK: - Statistics Card
    private var statisticsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("detail.statistics.title")
                .font(.headline)
            
            Divider()
            
            StatisticRowView(
                title: NSLocalizedString("detail.statistics.market_cap", comment: ""),
                value: (coin.marketCap ?? 0).toFormattedString()
            )
            StatisticRowView(
                title: NSLocalizedString("detail.statistics.market_cap_rank", comment: ""),
                value: "#\(coin.marketCapRank ?? 0)"
            )
            StatisticRowView(
                title: NSLocalizedString("detail.statistics.high_24h", comment: ""),
                value: (coin.high24H ?? 0).toCurrencyString()
            )
            StatisticRowView(
                title: NSLocalizedString("detail.statistics.low_24h", comment: ""),
                value: (coin.low24H ?? 0).toCurrencyString()
            )
            StatisticRowView(
                title: NSLocalizedString("detail.statistics.total_volume", comment: ""),
                value: (coin.totalVolume ?? 0).toFormattedString()
            )
        }
        .asCard()
    }
    
    // MARK: - Description Card
    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(String(format: NSLocalizedString("detail.about.title", comment: ""), coin.name))
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
                Text(isDescriptionExpanded ? "detail.about.show_less" : "detail.about.read_more")
                .font(.caption.bold())
                .foregroundStyle(.blue)
                .padding(.top, 4)
            }
        }
        .asCard()
    }
}

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
    func asCard() -> some View {
        self.modifier(CardViewModifier())
    }
}

#Preview {
    NavigationStack {
        CoinDetailView(coin: Coin.mock)
    }
}

