//
//  CoinRowSkeleton.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 09.11.2025.
//


import SwiftUI
import Shimmer

struct CoinRowSkeletonView: View {
    
   
    
    var body: some View {
        HStack(spacing: 12) {
            
            
            Circle()
                .frame(width: 32, height: 32)
            
            
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 6)
                    .frame(width: 120, height: 14)
                RoundedRectangle(cornerRadius: 6)
                    .frame(width: 60, height: 12)
            }
            
            Spacer()
            
           
            VStack(alignment: .trailing, spacing: 6) {
                RoundedRectangle(cornerRadius: 6)
                    .frame(width: 90, height: 14)
                RoundedRectangle(cornerRadius: 6)
                    .frame(width: 50, height: 12)
            }
        }
        .padding(.vertical, 8)
        .foregroundStyle(Color(.systemGray5))
        .shimmering()
    }
}

#Preview {
    
    List {
        ForEach(0..<10) { _ in
            CoinRowSkeletonView()
        }
    }
    .listStyle(.plain)
}
