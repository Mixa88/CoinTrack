//
//  CoinTrackWidget.swift
//  CoinTrackWidget
//
//  Created by Михайло Тихонов on 11.11.2025.
//

import WidgetKit
import SwiftUI
import SwiftData


struct Provider: TimelineProvider {
    
    
    var modelContainer: ModelContainer = SharedModelContainer.sharedModelContainer
    
    
    let coinService = CoinDataService.shared
    let globalService = GlobalDataService.shared

    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(),
                    btcPrice: 100000.0,
                    marketCap: 3.5e12, // 3.5T
                    btcDominance: 57.5)
    }

  
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(),
                                btcPrice: 100000.0,
                                marketCap: 3.5e12,
                                btcDominance: 57.5)
        completion(entry)
    }

    
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        
        Task {
            do {
                
                async let coinsTask = coinService.fetchCoins()
                async let globalTask = globalService.fetchGlobalData()
                
                
                let (coins, globalData) = try await (coinsTask, globalTask)
                
                
                let btc = coins.first(where: { $0.id == "bitcoin" })
                let btcPrice = btc?.currentPrice ?? 0
                let marketCap = globalData?.marketCapUSD ?? 0
                let btcDominance = globalData?.btcDominance ?? 0
                
                
                let entry = SimpleEntry(date: Date(),
                                        btcPrice: btcPrice,
                                        marketCap: marketCap,
                                        btcDominance: btcDominance)
                
                
                let nextUpdate = Date().addingTimeInterval(60 * 15) // Оновити через 15 хвилин
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
                
            } catch {
                
                print("Error fetching widget data: \(error)")
                let entry = SimpleEntry(date: Date(), btcPrice: 0, marketCap: 0, btcDominance: 0)
                let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60 * 5)))
                completion(timeline)
            }
        }
    }
}


struct SimpleEntry: TimelineEntry {
    let date: Date
    let btcPrice: Double
    let marketCap: Double
    let btcDominance: Double
}


struct CoinTrackWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            VStack(alignment: .leading) {
                Text("Bitcoin (BTC)")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Text(entry.btcPrice.toCurrencyString())
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
            }
            
            Spacer()
            
            
            VStack(alignment: .leading, spacing: 4) {
                StatisticRowView(title: "Market Cap", value: entry.marketCap.toFormattedString())
                StatisticRowView(title: "BTC Dominance", value: entry.btcDominance.toDominanceString())
            }
        }
        .padding()
    }
}


@main
struct CoinTrackWidget: Widget {
    let kind: String = "CoinTrackWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CoinTrackWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .modelContainer(SharedModelContainer.sharedModelContainer)
        }
        .configurationDisplayName("CoinTrack Summary") // TODO: Localize
        .description("Shows live Bitcoin price and market stats.") // TODO: Localize
        .supportedFamilies([.systemSmall]) // Ми підтримуємо тільки малий віджет
    }
}


#Preview(as: .systemSmall) {
    CoinTrackWidget()
} timeline: {
    SimpleEntry(date: Date(), btcPrice: 101000.0, marketCap: 3.5e12, btcDominance: 57.5)
}
