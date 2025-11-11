//
//  CoinTrackWidget.swift
//  CoinTrackWidget
//
//  Created by Михайло Тихонов on 11.11.2025.
//

import WidgetKit
import SwiftUI
import SwiftData

// --- 1. "МОЗОК" ВІДЖЕТА ---
struct Provider: TimelineProvider {
    
    // Створюємо "спільний" контейнер (той самий, що й у додатку)
    var modelContainer: ModelContainer = SharedModelContainer.sharedModelContainer
    
    // Створюємо екземпляри наших сервісів
    let coinService = CoinDataService.shared
    let globalService = GlobalDataService.shared

    // --- 2. "ЗАГЛУШКА" (Placeholder) ---
    // Поки віджет завантажується, він показує це
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(),
                    btcPrice: 100000.0,
                    marketCap: 3.5e12, // 3.5T
                    btcDominance: 57.5)
    }

    // --- 3. "ЗНІМОК" (Snapshot) ---
    // Це для "галереї" віджетів
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(),
                                btcPrice: 100000.0,
                                marketCap: 3.5e12,
                                btcDominance: 57.5)
        completion(entry)
    }

    // --- 4. "ГОЛОВНА" ФУНКЦІЯ (Timeline) ---
    // Вона завантажує "живі" дані
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        // Запускаємо асинхронне завдання
        Task {
            do {
                // Запускаємо ОБИДВА запити паралельно
                async let coinsTask = coinService.fetchCoins()
                async let globalTask = globalService.fetchGlobalData()
                
                // Чекаємо на результати
                let (coins, globalData) = try await (coinsTask, globalTask)
                
                // --- Обробляємо дані ---
                let btc = coins.first(where: { $0.id == "bitcoin" })
                let btcPrice = btc?.currentPrice ?? 0
                let marketCap = globalData?.marketCapUSD ?? 0
                let btcDominance = globalData?.btcDominance ?? 0
                
                // Створюємо "запис" (Entry) з "живими" даними
                let entry = SimpleEntry(date: Date(),
                                        btcPrice: btcPrice,
                                        marketCap: marketCap,
                                        btcDominance: btcDominance)
                
                // "Кажемо" iOS оновити віджет
                let nextUpdate = Date().addingTimeInterval(60 * 15) // Оновити через 15 хвилин
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
                
            } catch {
                // Якщо помилка, створюємо "порожній" запис
                print("Error fetching widget data: \(error)")
                let entry = SimpleEntry(date: Date(), btcPrice: 0, marketCap: 0, btcDominance: 0)
                let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60 * 5))) // Спробувати знову через 5 хв
                completion(timeline)
            }
        }
    }
}

// --- 5. "МОДЕЛЬ" ВІДЖЕТА (Оновлена) ---
struct SimpleEntry: TimelineEntry {
    let date: Date
    let btcPrice: Double
    let marketCap: Double
    let btcDominance: Double
}

// --- 6. UI ВІДЖЕТА (Оновлений) ---
struct CoinTrackWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        // Ми створюємо "маленький" дашборд
        VStack(alignment: .leading, spacing: 8) {
            // -- Рядок 1: Bitcoin --
            VStack(alignment: .leading) {
                Text("Bitcoin (BTC)")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Text(entry.btcPrice.toCurrencyString())
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
            }
            
            Spacer()
            
            // -- Рядок 2: Статистика --
            VStack(alignment: .leading, spacing: 4) {
                StatisticRowView(title: "Market Cap", value: entry.marketCap.toFormattedString())
                StatisticRowView(title: "BTC Dominance", value: entry.btcDominance.toDominanceString())
            }
        }
        .padding()
    }
}

// --- 7. "ГОЛОВНА" ЧАСТИНА (Без змін) ---
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

// --- 8. Preview (Оновлений) ---
#Preview(as: .systemSmall) {
    CoinTrackWidget()
} timeline: {
    SimpleEntry(date: Date(), btcPrice: 101000.0, marketCap: 3.5e12, btcDominance: 57.5)
}
