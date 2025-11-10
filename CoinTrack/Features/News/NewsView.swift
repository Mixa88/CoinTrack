//
//  NewsView.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 09.11.2025.
//


import SwiftUI

struct NewsView: View {
    
    @StateObject private var viewModel = NewsViewModel()
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                if viewModel.isLoading {
                    // ... (Твій код "Скелетону" тут)
                    List {
                        ForEach(0..<10) { _ in
                            CoinRowSkeletonView()
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                
                } else {
                    // --- 3. The real data ---
                    List(viewModel.articles) { article in
                        
                        // --- 2. THE FIX IS HERE ---
                        // We link to the SOURCE URL, not the article URL
                        if let urlString = article.source?.url, let url = URL(string: urlString) {
                            Link(destination: url) {
                                newsRow(article: article)
                            }
                        } else {
                            // If no URL, just show the row (not tappable)
                            newsRow(article: article)
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        await viewModel.fetchNews()
                    }
                }
                
                // --- 5. Error Overlay ---
                if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 36))
                        Text("Failed to load news")
                            .font(.headline)
                        
                        // Show the actual error
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                        
                        Button("Retry") {
                            Task { await viewModel.fetchNews() }
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                }
            } // --- End of ZStack
            .navigationTitle("News")
        }
    }
    
    // --- 6. Helper View for our News Row ---
    @ViewBuilder
    private func newsRow(article: NewsArticle) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            
            // --- 2. THE FIX IS HERE ---
            // Use ?? to provide a default value if data is nil
            Text(article.title ?? "No Title")
                .font(.headline)
                .foregroundStyle(.primary)
            
            // --- 3. THE FIX IS HERE ---
            // Use ?. to safely access optional `source`
            Text(article.source?.domain ?? "No Source")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NewsView()
}
