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
    @Published var selectedTab: ListTab = .allCoins
    
    // --- Data Lists ---
    @Published private var allCoins: [Coin] = []
    @Published private var portfolioCoinIDs: Set<String> = []
    
    // 3. This is our "smart" list that the UI will use.
    var coins: [Coin] {
        // Filter by search text first
        let filteredBySearch = filter(coins: allCoins, with: searchText)
        
        // Then, filter by tab
        switch selectedTab {
        case .allCoins:
            return filteredBySearch
        case .portfolio:
            return filteredBySearch.filter { portfolioCoinIDs.contains($0.id) }
        }
    }
    
    // --- Services ---
    private let dataService = CoinDataService.shared
    private var portfolioService: PortfolioDataService? // 4. This is now OPTIONAL
    private var cancellables = Set<AnyCancellable>()

    // 5. Simple, empty init
    init() {
        Task {
            await fetchCoins()
        }
    }
    
    // 6. NEW setup function (called from View)
    func setup(modelContext: ModelContext) {
        // If service already exists, don't create it again
        guard self.portfolioService == nil else { return }
        
        let service = PortfolioDataService(modelContext: modelContext)
        self.portfolioService = service
        subscribeToPortfolio(service: service) // Start listening
    }
    
    // 7. "Listens" to the database
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
    
    // 8. --- THIS IS THE HELPER FUNCTION THAT WAS MISSING ---
    // This function filters our coins based on search text
    private func filter(coins: [Coin], with text: String) -> [Coin] {
        guard !text.isEmpty else {
            return coins // Return all if search is empty
        }
        
        let lowercasedText = text.lowercased()
        return coins.filter { coin in
            coin.name.lowercased().contains(lowercasedText) ||
            coin.symbol.lowercased().contains(lowercasedText)
        }
    }
    
    // --- PUBLIC FUNCTIONS (for UI) ---
    
    func refreshCoins() async {
        self.errorMessage = nil
        do {
            let fetchedCoins = try await dataService.fetchCoins()
            self.allCoins = fetchedCoins
        } catch {
            self.errorMessage = error.localizedDescription
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
    
    private func fetchCoins() async {
        self.isLoading = true
        await refreshCoins() // Call the refresh function
        self.isLoading = false
    }
}
