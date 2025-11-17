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
        SimpleEntry(
            date: Date(),
            btcPrice: 100000.0,
            marketCap: 3.5e12,
            btcDominance: 57.5
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(
            date: Date(),
            btcPrice: 100000.0,
            marketCap: 3.5e12,
            btcDominance: 57.5
        )
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

                let entry = SimpleEntry(
                    date: Date(),
                    btcPrice: btcPrice,
                    marketCap: marketCap,
                    btcDominance: btcDominance
                )

                let nextUpdate = Date().addingTimeInterval(60 * 15)
                completion(Timeline(entries: [entry], policy: .after(nextUpdate)))

            } catch {
                let entry = SimpleEntry(date: Date(), btcPrice: 0, marketCap: 0, btcDominance: 0)
                completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60 * 5))))
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
            
            // --- BTC TITLE + PRICE ---
            VStack(alignment: .leading) {
                Text("widget.btc")                     
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                
                Text(entry.btcPrice.toCurrencyString())
                    .font(.title2.bold())
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(.primary)
            }
            
            Spacer()
            
            // --- STATISTICS ---
            HStack {
                
                VStack(alignment: .leading) {
                    Text(entry.marketCap.toFormattedString())
                        .font(.caption.bold())
                        .minimumScaleFactor(0.8)
                    
                    Text("widget.stats.market_cap")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                
                VStack(alignment: .trailing) {
                    Text(entry.btcDominance.toDominanceString())
                        .font(.caption.bold())
                        .minimumScaleFactor(0.8)
                    
                    Text("detail.statistics.btc_dominance_short")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1) // 
                }
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
        .configurationDisplayName(Text("widget.display_name"))
        .description(Text("widget.description"))
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    CoinTrackWidget()
} timeline: {
    SimpleEntry(date: Date(), btcPrice: 101000.0, marketCap: 3.5e12, btcDominance: 57.5)
}

