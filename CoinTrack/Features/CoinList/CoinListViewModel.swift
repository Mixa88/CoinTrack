//
//  CoinListViewModel.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 06.11.2025.
//

import Foundation
import Combine
import SwiftData 

@MainActor
class CoinListViewModel: ObservableObject {
    
    // --- Published Properties (for the UI) ---
    @Published var isLoading = true
    @Published var errorMessage: String? = nil
    @Published var searchText = ""
    
    // 2. THIS IS THE ENUM (It must be defined *before* use)
    enum ListTab {
        case allCoins
        case portfolio
    }
    // 3. The property that USES the enum
    @Published var selectedTab: ListTab = .allCoins
    
    // --- NEW: Global Data ---
    @Published var globalData: GlobalData?
    
    // --- Data Lists ---
    @Published private var allCoins: [Coin] = []
    @Published private var portfolioCoinIDs: Set<String> = []
    
    // 4. This is our "smart" list that the UI will use.
    var coins: [Coin] {
        let filteredBySearch = filter(coins: allCoins, with: searchText)
        
        switch selectedTab {
        case .allCoins:
            return filteredBySearch
        case .portfolio:
            return filteredBySearch.filter { portfolioCoinIDs.contains($0.id) }
        }
    }
    
    // --- Services ---
    private let coinDataService = CoinDataService.shared
    private let globalDataService = GlobalDataService.shared // 5. ADDED SERVICE
    private var portfolioService: PortfolioDataService?
    private var cancellables = Set<AnyCancellable>()

    // 6. Simple, empty init
    init() {
        Task {
            await fetchAllData() // Call the "master" fetch
        }
    }
    
    // 7. NEW setup function (called from View)
    func setup(modelContext: ModelContext) {
        guard self.portfolioService == nil else { return }
        let service = PortfolioDataService(modelContext: modelContext)
        self.portfolioService = service
        subscribeToPortfolio(service: service) // Start listening
    }
    
    // 8. "Listens" to the database
    private func subscribeToPortfolio(service: PortfolioDataService) {
        service.$savedEntities
            .map { entities -> Set<String> in
                Set(entities.map { $0.coinID })
            }
            .sink { [weak self] returnedCoinIDs in
                self?.portfolioCoinIDs = returnedCoinIDs
            }
            .store(in: &cancellables)
    }
    
    // 9. --- THIS IS THE HELPER FUNCTION THAT WAS MISSING ---
    private func filter(coins: [Coin], with text: String) -> [Coin] {
        guard !text.isEmpty else {
            return coins
        }
        let lowercasedText = text.lowercased()
        return coins.filter { coin in
            coin.name.lowercased().contains(lowercasedText) ||
            coin.symbol.lowercased().contains(lowercasedText)
        }
    }
    
    // --- PUBLIC FUNCTIONS (for UI) ---
    
    // 10. This is the new "master" refresh
    func refreshAllData() async {
        self.errorMessage = nil
        
        // Run both API calls in parallel
        async let fetchCoinsTask = coinDataService.fetchCoins()
        async let fetchGlobalDataTask = globalDataService.fetchGlobalData()
        
        do {
            // Wait for both to complete
            let (fetchedCoins, fetchedGlobalData) = try await (fetchCoinsTask, fetchGlobalDataTask)
            
            self.allCoins = fetchedCoins
            self.globalData = fetchedGlobalData
            print("Successfully refreshed all data.")
            
        } catch {
            self.errorMessage = error.localizedDescription
            print("Failed to refresh all data: \(error)")
        }
    }
    
    func updatePortfolio(coin: Coin) {
        guard let portfolioService = portfolioService else { return }
        if coinIsInPortfolio(coin: coin) {
            portfolioService.removeCoin(coinID: coin.id)
        } else {
            portfolioService.addCoin(coinID: coin.id)
        }
    }
    
    func coinIsInPortfolio(coin: Coin) -> Bool {
        return portfolioCoinIDs.contains(coin.id)
    }

    // --- PRIVATE FUNCTIONS ---
    
    // 11. This is the initial load function
    private func fetchAllData() async {
        self.isLoading = true
        await refreshAllData() // Call the "master" refresh
        self.isLoading = false
    }
}
