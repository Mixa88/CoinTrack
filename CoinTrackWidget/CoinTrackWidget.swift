//
//  CoinTrackWidget.swift
//  CoinTrackWidget
//
//  Created by Михайло Тихонов on 11.11.2025.
//

// CoinTrackWidget.swift
import WidgetKit
import SwiftUI
import SwiftData

// --- 1. ПРОВАЙДЕР (Мозок Віджета) ---
// (Ми поки не чіпаємо його логіку, просто "чистимо")
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // --- TODO: Тут ми будемо завантажувати дані ---
        // (Поки що просто оновлюємо раз на годину)
        let entries: [SimpleEntry] = [SimpleEntry(date: Date())]
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// --- 2. "МОДЕЛЬ" ВІДЖЕТА ---
struct SimpleEntry: TimelineEntry {
    let date: Date
    // --- TODO: Тут будуть наші монети ---
    // let btcPrice: Double
}

// --- 3. UI ВІДЖЕТА ---
struct CoinTrackWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("CoinTrack")
                .font(.headline)
            Text(entry.date, style: .time)
                .font(.caption)
            
            // --- TODO: Тут буде UI для BTC ---
        }
    }
}

// --- 4. "ГОЛОВНА" ЧАСТИНА (Ось тут виправлення) ---
@main
struct CoinTrackWidget: Widget {
    let kind: String = "CoinTrackWidget"

    var body: some WidgetConfiguration {
        // 5. Ми використовуємо "простий" StaticConfiguration
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CoinTrackWidgetEntryView(entry: entry)
                // 6. "Затишний" фон
                .containerBackground(.fill.tertiary, for: .widget)
                .modelContainer(SharedModelContainer.sharedModelContainer)
        }
        .configurationDisplayName("My Coin Widget") // TODO: Localize
        .description("Shows the price of your favorite coins.") // TODO: Localize
       
        
    }
}

// --- 5. Preview ---
#Preview(as: .systemSmall) {
    CoinTrackWidget()
} timeline: {
    SimpleEntry(date: Date())
}
