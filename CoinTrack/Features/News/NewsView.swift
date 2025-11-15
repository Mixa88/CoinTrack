//
//  NewsView.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 09.11.2025.
//


// NewsView.swift
import SwiftUI

struct NewsView: View {
    
    @StateObject private var viewModel = NewsViewModel()
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                if viewModel.isLoading {
                    // --- Loading Skeletons ---
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
                        
                        // We link to the article URL
                        if let url = article.articleURL {
                            Link(destination: url) {
                                newsRow(article: article) // Use our "cozy" helper
                            }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        await viewModel.fetchNews()
                    }
                }
                
                // --- Error Overlay ---
                if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 36))
                        Text("Failed to load news")
                            .font(.headline)
                        
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
    
    // --- 6. "COZY" NEWS ROW ---
    // We now display the image and the source name
    @ViewBuilder
    private func newsRow(article: NewsArticle) -> some View {
        HStack(spacing: 12) {
            // --- 1. Image ---
            AsyncImage(url: URL(string: article.imageUrl)) { image in
                image.resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .frame(width: 60, height: 60)
                    .foregroundStyle(Color(.systemGray5))
            }
            
            // --- 2. Text ---
            VStack(alignment: .leading, spacing: 6) {
                Text(article.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(3) // Limit to 3 lines
                
                Text(article.source.uppercased()) // "CNN", "CoinTelegraph"
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NewsView()
}
