//
//  LockView.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 11.11.2025.
//


import SwiftUI

struct LockView: View {
    
    // 1. This View expects to receive the "gatekeeper"
    @ObservedObject var viewModel: AppLockViewModel
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // 2. Icon
            Image(systemName: "faceid")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            // 3. Title
            Text("CoinTrack is Locked") // TODO: Localize
                .font(.largeTitle.bold())
            
            Text("Unlock with biometrics to continue.") // TODO: Localize
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            // 4. The Button
            Button {
                viewModel.authenticate() // Call the "brain"
            } label: {
                Label("Unlock Now", systemImage: "faceid") // TODO: Localize
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
            // 5. Automatically try to unlock when the view appears
            viewModel.authenticate()
        }
    }
}

#Preview {
    // We need a "mock" VM for the preview
    LockView(viewModel: AppLockViewModel())
}
