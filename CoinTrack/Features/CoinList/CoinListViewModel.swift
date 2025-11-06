//
//  CoinListViewModel.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 06.11.2025.
//


// CoinListViewModel.swift
import Foundation

@MainActor
class CoinListViewModel: ObservableObject {
    
    // 1. --- CHANGED ---
    // `allCoins` is our private, master list
    @Published private var allCoins: [Coin] = []
    
    // `coins` is now a COMPUTED PROPERTY (умная переменная)
    // The UI will always get its list from here.
    var coins: [Coin] {
        // If search text is empty, return all coins
        if searchText.isEmpty {
            return allCoins
        } else {
            // If search text is NOT empty, filter the master list
            let lowercasedText = searchText.lowercased()
            return allCoins.filter { coin in
                coin.name.lowercased().contains(lowercasedText) ||
                coin.symbol.lowercased().contains(lowercasedText)
            }
        }
    }
    
    @Published var isLoading = true
    @Published var errorMessage: String? = nil
    @Published var searchText = ""
    
    private let dataService = CoinDataService.shared
    
    init() {
        Task {
            await fetchCoins()
        }
    }
    
    func fetchCoins() async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let fetchedCoins = try await dataService.fetchCoins()
            
            // 2. --- CHANGED ---
            // We now save data to our master list `allCoins`
            self.allCoins = fetchedCoins
            self.isLoading = false
            
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
            print("Failed to fetch coins: \(error)")
        }
    }
    
    func refreshCoins() async {
        self.errorMessage = nil
        
        do {
            let fetchedCoins = try await dataService.fetchCoins()
            
            // 3. --- CHANGED ---
            // We also update the master list `allCoins` here
            self.allCoins = fetchedCoins
            
        } catch {
            self.errorMessage = error.localizedDescription
            print("Failed to refresh coins: \(error)")
        }
    }
}
