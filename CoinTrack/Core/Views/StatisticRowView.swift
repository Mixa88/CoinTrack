//
//  StatisticRowView.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 11.11.2025.
//

import SwiftUI

struct StatisticRowView: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    StatisticRowView(
        title: NSLocalizedString("detail.statistics.market_cap", comment: ""), // <- Ключ
        value: "2.0T"
    )
}
