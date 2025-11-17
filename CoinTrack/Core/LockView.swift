//
//  LockView.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 11.11.2025.
//



import SwiftUI

struct LockView: View {
    
    @ObservedObject var viewModel: AppLockViewModel
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Image(systemName: "faceid")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            Text("lock.title")
                .font(.largeTitle.bold())
            
            Text("lock.subtitle")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Button {
                viewModel.authenticate()
            } label: {
                Label("lock.button", systemImage: "faceid") 
                    .font(.headline.bold())
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .padding(40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            viewModel.authenticate()
        }
    }
}

#Preview {
    LockView(viewModel: AppLockViewModel())
}
