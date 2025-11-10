//
//  CoinTrackApp.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 06.11.2025.
//


import SwiftUI
import SwiftData
import UserNotifications

@main
struct CoinTrackApp: App {
    
    
    init() {
        requestNotificationAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: PortfolioEntity.self)
    }
    
    private func requestNotificationAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound] // We ask for alert + sound
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if success {
                print("Notifications allowed!")
            } else if let error = error {
                print("Notification error: \(error.localizedDescription)")
            }
        }
    }
}
