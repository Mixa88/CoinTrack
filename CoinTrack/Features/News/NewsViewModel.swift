//
//  NewsViewModel.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 10.11.2025.
//

import Foundation

@MainActor
class NewsViewModel: ObservableObject {
    
    
    @Published var articles: [NewsArticle] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    
    private let dataService = NewsDataService.shared
    
    init() {
        
        Task {
            await fetchNews()
        }
    }
    
    
    func fetchNews() async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            
            let fetchedArticles = try await dataService.fetchNews()
            
            
            self.articles = fetchedArticles
            self.isLoading = false
            
        } catch {
            
            self.errorMessage = error.localizedDescription
            self.isLoading = false
            print("Failed to fetch news: \(error)")
        }
    }
}
