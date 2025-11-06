//
//  CoinListViewModel.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 06.11.2025.
//

// CoinListViewModel.swift
import Foundation

// 1. @MainActor ensures that all updates to our @Published
// variables happen on the main thread (which is required for UI).
@MainActor
class CoinListViewModel: ObservableObject {
    
    // 2. These are the "signals" our View will listen for.
    @Published var coins: [Coin] = [] // The list of coins to display
    @Published var isLoading = true   // To show a loading spinner
    @Published var errorMessage: String? = nil // To show an error message
    
    // 3. A reference to our network service
    private let dataService = CoinDataService.shared
    
    init() {
        // 4. When the ViewModel is created, immediately start
        // fetching the coins in a background task.
        Task {
            await fetchCoins()
        }
    }
    
    // 5. The function that calls our service
    func fetchCoins() async {
        // 6. Reset state before fetching
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            // 7. Try to get the coins from the service.
            // This line will "pause" until the network request is done.
            let fetchedCoins = try await dataService.fetchCoins()
            
            // 8. Success! Update our published property.
            self.coins = fetchedCoins
            self.isLoading = false
            
        } catch {
            // 9. Failure. Store the error message.
            self.errorMessage = error.localizedDescription
            self.isLoading = false
            print("Failed to fetch coins: \(error)")
        }
    }
}
