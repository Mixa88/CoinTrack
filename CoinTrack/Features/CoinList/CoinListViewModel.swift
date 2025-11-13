//
//  CoinListViewModel.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 06.11.2025.
//


import Foundation
import Combine
import SwiftData
import UserNotifications // Потрібен для сповіщень

@MainActor
class CoinListViewModel: ObservableObject {
    
    // --- Published Properties (for the UI) ---
    @Published var isLoading = true
    @Published var errorMessage: String? = nil
    @Published var searchText = ""
    enum ListTab {
        case allCoins
        case portfolio
    }
    @Published var selectedTab: ListTab = .allCoins
    
    // --- Data Properties ---
    @Published var globalData: GlobalData?
    @Published var fearGreedData: FearGreedData?
    @Published var spotlightCoin: Coin? // <-- Ось наша "Монета дня"
    @Published private var allCoins: [Coin] = []
    @Published private var portfolioCoinIDs: Set<String> = []
    
    // --- Computed Property (Розумний список) ---
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
    private let globalDataService = GlobalDataService.shared
    private let fearGreedService = FearGreedDataService.shared
    private let spotlightService = SpotlightService() // <-- Ось наш "Сервіс Монети дня"
    private var portfolioService: PortfolioDataService?
    private var cancellables = Set<AnyCancellable>()

    // --- Init & Setup ---
    init() {
        Task {
            await fetchAllData() // Викликаємо "майстер-функцію"
        }
    }
    
    func setup(modelContext: ModelContext) {
        // "Вмикаємо" SwiftData, коли View готовий
        guard self.portfolioService == nil else { return }
        let service = PortfolioDataService(modelContext: modelContext)
        self.portfolioService = service
        subscribeToPortfolio(service: service) // Починаємо "слухати" базу
    }
    
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
    
    // --- PUBLIC FUNCTIONS (for UI) ---
    
    
    func refreshAllData() async {
        self.errorMessage = nil
        
        
        async let fetchCoinsTask = coinDataService.fetchCoins()
        async let fetchGlobalDataTask = globalDataService.fetchGlobalData()
        async let fetchFearGreedTask = fearGreedService.fetchFearGreedIndex()
        
        do {
            
            let (fetchedCoins, fetchedGlobalData, fetchedFearGreedData) =
                try await (fetchCoinsTask, fetchGlobalDataTask, fetchFearGreedTask)
            
            
            self.allCoins = fetchedCoins
            self.globalData = fetchedGlobalData
            self.fearGreedData = fetchedFearGreedData
            
            
            self.spotlightCoin = spotlightService.getSpotlightCoin(from: fetchedCoins)
            
            checkAlerts()
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
    
    
    private func fetchAllData() async {
        self.isLoading = true
        await refreshAllData()
        self.isLoading = false
    }
    
    
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
    
    
    private func checkAlerts() {
        let portfolioCoins = allCoins.filter { portfolioCoinIDs.contains($0.id) }
        
        for coin in portfolioCoins {
            if let priceChange = coin.priceChangePercentage24H, abs(priceChange) > 5.0 {
                sendNotification(for: coin, change: priceChange)
            }
        }
    }
    
    private func sendNotification(for coin: Coin, change: Double) {
        let content = UNMutableNotificationContent()
        content.title = "\(coin.name) Price Alert"
        let direction = change > 0 ? "increased" : "decreased"
        content.body = "\(coin.symbol.uppercased()) has \(direction) by \(change.toPercentString()) in 24h!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: coin.id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
