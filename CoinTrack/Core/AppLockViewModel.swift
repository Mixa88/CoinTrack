//
//  AppLockViewModel.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 11.11.2025.
//

import Foundation
import LocalAuthentication
import SwiftUI

@MainActor
class AppLockViewModel: ObservableObject {
    
    // 1. This is the "gate". If false, we show the lock screen.
    @Published var isUnlocked = false
    
    // 2. We'll add a setting later, for now, let's assume it's ON
    // @AppStorage("isAppLockEnabled") var isAppLockEnabled = false
    
    init() {
        // For now, let's start locked
        // Later, we'll check `isAppLockEnabled`
        isUnlocked = false
    }
    
    
    func authenticate() {
            let context = LAContext()
            var error: NSError?
        let reason = NSLocalizedString("lock.reason", comment: "")

            // 1. Check if we *can* evaluate
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                
                // 2. YES, we can (this will run on a REAL device)
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { [weak self] success, authenticationError in
                    
                    DispatchQueue.main.async {
                        if success {
                            print("Face ID/Touch ID Success!")
                            self?.isUnlocked = true
                        } else {
                            print("Face ID/Touch ID Failed.")
                            // Stay locked
                        }
                    }
                }
            } else {
                // 3. NO, we cannot (Biometrics not available or SIMULATOR BUG)
                print("Biometrics not available. Error: \(error?.localizedDescription ?? "Unknown")")
                
                // --- 4. THIS IS OUR "BACKDOOR" FOR SIMULATOR ---
                #if targetEnvironment(simulator)
                // If we are ON THE SIMULATOR, unlock the app
                // so we can continue developing.
                print("Simulator detected: Bypassing lock screen.")
                DispatchQueue.main.async {
                    self.isUnlocked = true
                }
                #endif
                // On a REAL device without Face ID, it will just stay locked.
            }
        }
}
