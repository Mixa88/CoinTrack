//
//  NewsViewModel.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 10.11.2025.
//

import Foundation

@MainActor
class NewsViewModel: ObservableObject {
    
    // 1. "Сигнали" для нашого UI
    @Published var articles: [NewsArticle] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    // 2. Посилання на наш "сервіс"
    private let dataService = NewsDataService.shared
    
    init() {
        // 3. Одразу завантажуємо новини при створенні "мозку"
        Task {
            await fetchNews()
        }
    }
    
    // 4. Функція завантаження
    func fetchNews() async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            // 5. Викликаємо сервіс
            let fetchedArticles = try await dataService.fetchNews()
            
            // 6. Успіх! Оновлюємо UI
            self.articles = fetchedArticles
            self.isLoading = false
            
        } catch {
            // 7. Помилка
            self.errorMessage = error.localizedDescription
            self.isLoading = false
            print("Failed to fetch news: \(error)")
        }
    }
}
