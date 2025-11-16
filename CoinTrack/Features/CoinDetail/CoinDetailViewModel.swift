//
//  CoinDetailViewModel.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 06.11.2025.
//

import Foundation

@MainActor
class CoinDetailViewModel: ObservableObject {
    
    // --- Published Properties ---
    @Published var chartData: [Double] = []
    
    // 1. --- ADD NEW PROPERTY ---
    // This will hold the "en" description string
    @Published var description: String?
    
    @Published var isLoading = true // Changed to `true` to show loading on init
    @Published var errorMessage: String? = nil
    
    private let dataService: CoinDetailDataService
    
    init(coin: Coin) {
        self.dataService = CoinDetailDataService(coinID: coin.id)
        
        // 2. Start fetching ALL data
        Task {
            await fetchAllDetailData()
        }
    }
    
    // 3. --- RENAMED & UPGRADED FUNCTION ---
    // This is now our "master" fetch function
    func fetchAllDetailData() async {
        self.isLoading = true
        self.errorMessage = nil
        
        // 4. --- ASYNC MAGIC ---
        // Start both network calls in parallel
        async let fetchChartTask = dataService.fetchChartData()
        async let fetchDescriptionTask = dataService.fetchCoinDescription()
        
        do {
            // 5. Wait for both to complete
            let (coinDetail, coinFullDetail) = try await (fetchChartTask, fetchDescriptionTask)
            
            // 6. Update our properties
            self.chartData = coinDetail.prices.compactMap { $0.count > 1 ? $0[1] : nil } // Process chart data
            let dirtyDescription = coinFullDetail?.description?.englishDescription
            self.description = dirtyDescription?.stripHTML() ?? "No description available."
            
            self.isLoading = false
            print("Successfully fetched all detail data.")
            
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
            print("Failed to fetch all detail data: \(error)")
        }
    }
}
