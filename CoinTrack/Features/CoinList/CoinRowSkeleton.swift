//
//  CoinRowSkeleton.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 09.11.2025.
//


import SwiftUI
import Shimmer

struct CoinRowSkeletonView: View {
    
    // Ми "застосуємо" .shimmering() до всієї ячейки
    // для кращої продуктивності
    
    var body: some View {
        HStack(spacing: 12) {
            
            // --- 1. "Скелетон" іконки ---
            Circle()
                .frame(width: 32, height: 32)
            
            // --- 2. "Скелетон" Назви та Символу ---
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 6)
                    .frame(width: 120, height: 14)
                RoundedRectangle(cornerRadius: 6)
                    .frame(width: 60, height: 12)
            }
            
            Spacer() // Розтягуємо
            
            // --- 3. "Скелетон" Ціни та % ---
            VStack(alignment: .trailing, spacing: 6) {
                RoundedRectangle(cornerRadius: 6)
                    .frame(width: 90, height: 14)
                RoundedRectangle(cornerRadius: 6)
                    .frame(width: 50, height: 12)
            }
        }
        .padding(.vertical, 8)
        .foregroundStyle(Color(.systemGray5)) // Робимо всі фігури "затишно" сірими
        .shimmering() // І змушуємо всю ячейку мерехтіти
    }
}

#Preview {
    // Ми можемо зробити список скелетонів у прев'ю
    List {
        ForEach(0..<10) { _ in
            CoinRowSkeletonView()
        }
    }
    .listStyle(.plain)
}
