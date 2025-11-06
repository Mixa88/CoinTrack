//
//  CoinDetailViewModel.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 06.11.2025.
//

import Foundation

@MainActor
class CoinDetailViewModel: ObservableObject {
    
    // 1. Published properties for the UI to observe
    // This will store just the prices: [1.2, 1.5, 1.3]
    @Published var chartData: [Double] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    // 2. The service that fetches data
    private let dataService: CoinDetailDataService
    
    // 3. The initializer receives the coin
    // This is how we pass the coinID to the service
    init(coin: Coin) {
        self.dataService = CoinDetailDataService(coinID: coin.id)
        
        // 4. Start fetching the chart data as soon as the VM is created
        Task {
            await fetchChartData()
        }
    }
    
    // 5. The function that calls the service
    func fetchChartData() async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            // 6. Call the service
            let coinDetail = try await dataService.fetchChartData()
            
            // 7. Process the data
            // The API gives us [[Timestamp, Price], [Timestamp, Price]]
            // We only want the Price: [Price, Price]
            self.chartData = coinDetail.prices.map { $0[1] } // Get the second element (price)
            
            self.isLoading = false
            print("Successfully fetched chart data. \(self.chartData.count) points.")
            
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
            print("Failed to fetch chart data: \(error)")
        }
    }
}
