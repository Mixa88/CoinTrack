//
//  NewsView.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 09.11.2025.
//

import SwiftUI
import SafariServices

struct NewsView: View {
    
    
    @StateObject private var viewModel = NewsViewModel()
    
    @State private var selectedArticleURL: URL?
    
    var body: some View {
        NavigationStack {
            
            ZStack {
            
                if viewModel.isLoading {
                    List {
                        ForEach(0..<10) { _ in
                            CoinRowSkeletonView()
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                
                
                } else {
                    List {
                        Section {
                            ForEach(viewModel.articles) { article in
                                
                                
                                newsRow(article: article)
                                    .onTapGesture {
                                        if let url = article.articleURL {
                                            
                                            self.selectedArticleURL = url
                                        }
                                    }
                            }
                        }
                        
                        VStack {
                            Spacer()
                            VStack(spacing: 4) {
                                Text("News is automatically sourced from the CryptoCompare News API.")
                                Text("CoinTrack does not create, edit, or verify external content.")
                            }
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 16)
                            .background(.ultraThinMaterial) // "Затишна" напівпрозора плашка
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        await viewModel.fetchNews()
                    }
                }
                
               
            
                
                
                if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 36))
                            .foregroundStyle(.gray)
                        Text("Failed to load news") // TODO: Localize
                            .font(.headline)
                        
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                        
                        Button("Retry") { // TODO: Localize
                            Task { await viewModel.fetchNews() }
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .padding(.horizontal, 40)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .navigationTitle("News") // TODO: Localize
            
            
            .sheet(item: $selectedArticleURL) { url in
                SafariView(url: url)
            }
        }
    }
    

    @ViewBuilder
    private func newsRow(article: NewsArticle) -> some View {
        
        VStack { // We use a VStack to hold the padding
                    HStack(spacing: 12) {
                        // --- Image ---
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
                        
                        // --- Text ---
                        VStack(alignment: .leading, spacing: 6) {
                            Text(article.title)
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .lineLimit(2) // <-- 2. "ДОПИЛ" (як радив друг)
                            
                            Text(article.source.uppercased())
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(8) // "Затишний" внутрішній відступ
                .background(Color(.secondarySystemBackground)) // Використовуємо "чистий" колір
                .cornerRadius(16) 
            }
    }



struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // Нічого не оновлюємо
    }
}


extension URL: Identifiable {
    public var id: String { self.absoluteString }
}



#Preview {
    NewsView()
}
