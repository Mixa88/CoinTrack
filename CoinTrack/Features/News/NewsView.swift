//
//  NewsView.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 09.11.2025.
//


import SwiftUI

struct NewsView: View {
    
    // 1. We create the "brain" for this screen
    @StateObject private var viewModel = NewsViewModel()
    
    var body: some View {
            NavigationStack {
                
                ZStack { // --- The main ZStack ---
                    // --- A. LOADING STATE (SKELETONS) ---
                    if viewModel.isLoading {
                        List {
                            ForEach(0..<10) { _ in
                                CoinRowSkeletonView()
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                            }
                        }
                        .listStyle(.plain)
                    
                    // --- B. LOADED STATE (CONTENT) ---
                    } else {
                        List { // Only the news section
                            Section {
                                ForEach(viewModel.articles) { article in
                                    if let url = article.articleURL {
                                        Link(destination: url) {
                                            newsRow(article: article)
                                        }
                                    } else {
                                        newsRow(article: article)
                                    }
                                }
                            }
                        } // --- End of List ---
                        .listStyle(.plain)
                        .refreshable {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            await viewModel.fetchNews()
                        }
                    }
                    
                    // --- C. THE DISCLAIMER (ALWAYS VISIBLE, AT THE BOTTOM) ---
                    // We're wrapping it in a VStack with a Spacer to push it to the bottom
                    VStack {
                        Spacer() // Pushes the disclaimer to the bottom
                        VStack(spacing: 4) {
                            Text("News is automatically sourced from the CryptoCompare News API.") // TODO: Localize
                            Text("CoinTrack does not create, edit, or verify external content.") // TODO: Localize
                        }
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 16)
                        .background(.ultraThinMaterial) // Your requested semi-transparent background
                    }
                    
                    // --- D. ERROR OVERLAY ---
                    if let errorMessage = viewModel.errorMessage {
                        VStack(spacing: 12) {
                            // ... (Your existing error overlay code) ...
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .padding(.horizontal, 40)
                        .transition(.scale.combined(with: .opacity))
                    }
                } // --- End of main ZStack
                .navigationTitle("News") // TODO: Localize
            }
        }
    
    // --- "COZY" NEWS ROW (HELPER VIEW) ---
    @ViewBuilder
    private func newsRow(article: NewsArticle) -> some View {
        HStack(spacing: 12) {
            // --- 1. Image ---
            AsyncImage(url: article.fullImageURL) { image in
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
                    .lineLimit(3)
                
                Text(article.source.uppercased())
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
