# 🚀 CoinTrack: Crypto Portfolio Tracker

**CoinTrack** is a clean, modern, and feature-rich cryptocurrency tracking app built entirely in **SwiftUI**. It's designed to be a "cozy" yet powerful tool for monitoring the market and your personal portfolio.

This project was built to demonstrate a deep understanding of modern iOS development, including **MVVM architecture**, **SwiftData**, **WidgetKit**, and advanced **Concurrency** with `async/await`.

### ✨ Key Features (Screenshots)

| Main List (Live Search) | Portfolio (SwiftData) |
| :---: | :---: |
| ![Main List](https://github.com/user-attachments/assets/ed7d3025-ba63-49c8-86c2-de52706259f7) | ![Portfolio](https://github.com/user-attachments/assets/61a40889-ddcc-4e23-a2b7-4304bf668c66) |
| **Detail View (Live Chart)** | **Widget & Face ID** |
| :---: | :---: |
| ![Detail View](https://github.com/user-attachments/assets/4b3a4ae8-0157-49b1-ba8c-a84da044ea09) | ![Widget + Lock](https://github.com/user-attachments/assets/5c5f25ef-4bde-462e-b22b-8a330347ca88) |

---

## ✨ Features

This app is more than just a simple list. It's packed with "premium" features that showcase a modern tech stack.

### Core Features
* **Live Prices:** Fetches real-time data for 100+ cryptocurrencies from the CoinGecko API.
* **Global Market Dashboard:** Displays a "cozy" dashboard with global market cap, 24h volume, BTC dominance, and the **Fear & Greed Index**.
* **Coin Detail View:** A tap-to-see detail screen showing a **live 7-day chart** (using `Charts`), detailed statistics, and a full "About" description.
* **"Coin of the Day"**: A spotlight card that algorithmically features a new coin every 24 hours (using `@AppStorage` to persist the choice).

### "Premium Polish" Features
* **Portfolio (Favorites):** Uses **SwiftData** to locally persist the user's favorite coins.
* **WidgetKit Extension:** A beautiful **Home Screen Widget** that shows live prices and market stats, powered by a **Shared App Group** and `SwiftData`.
* **Face ID / App Lock:** Secures the entire app on launch using **LocalAuthentication** (`.deviceOwnerAuthenticationWithBiometrics`).
* **Local Notifications:** Sends alerts to the user if a portfolio coin changes by more than 5% (using `UserNotifications`).
* **"Shimmer" Skeletons:** A "premium-looking" skeleton loading state (using `Shimmer`) instead of a simple `ProgressView`.
* **Live Search:** Instant search results using a `computed property` in the `ViewModel`.
* **Haptic Feedback:** Subtle vibrations (`UIImpactFeedbackGenerator`) on "Pull-to-Refresh" and other interactions.
* **Context Menu:** A "long-press" gesture (`.contextMenu`) on a coin row to show a "wow-effect" preview with quick stats.

---

## 🛠 Tech Stack & Architecture

This project was built using a clean **MVVM (Model-View-ViewModel)** architecture combined with a **Service Layer** to isolate network and data logic.

### Frameworks & APIs
* **SwiftUI:** The entire UI is built 100% in SwiftUI.
* **SwiftData:** Used for persisting the user's portfolio (`PortfolioEntity`).
* **WidgetKit:** Powers the Home Screen widget.
* **Charts:** Used for the 7-day sparkline on the `CoinDetailView`.
* **Combine:** Used in the `ViewModel` to subscribe to `PortfolioDataService` changes.
* **Concurrency (`async/await`):** All network requests are modern, parallel `async let` calls.
* **LocalAuthentication:** Used for the Face ID App Lock.
* **UserNotifications:** Used for price alerts.
* **Shimmer:** Third-party package for the skeleton loading effect.

### APIs Used
* **CoinGecko:** Used for all coin data, market data, and chart data.
* **CryptoPanic:** Used for the (currently non-functional) News tab.
* **alternative.me:** Used for the Fear & Greed Index.

---

## ⚙️ How to Run

1.  Clone the repository.
2.  Get your **free** API key from [CryptoPanic](https://cryptopanic.com/api/) (for the News feature).
3.  In the root directory, create a new file named `Secrets.swift`.
4.  Add the following code and paste your key:
    ```swift
    // Secrets.swift
    import Foundation
    
    enum Secrets {
        static let cryptoPanicAPIKey = "YOUR_KEY_HERE"
    }
    ```
5.  This file is already in the `.gitignore` and will not be committed.
6.  Build and run!

---

## ⚠️ Troubleshooting (WidgetKit Simulator Bug)

When testing the widget in the iOS simulator, you may encounter an error such as `Failed to show Widget (Error Code=8)` or the widget not appearing at all.

This happens because the simulator often fails to properly register the `App Group` or the `SwiftData` container.

**Solution:**
1.  **Run on a REAL DEVICE.** This is the easiest fix.
2.  If you must use the Simulator, the "Nuke Option" is required:
    * In Xcode: **Product → Clean Build Folder** (`Shift + Cmd + K`).
    * In Simulator: **Device → Erase All Content and Settings...**
    * In Xcode: Go to **Xcode → Settings... → Locations** and **delete the `DerivedData`** folder for this project.
    * Restart Xcode and run the **main `CoinTrack` app target** (not the widget target).
  
---

## 🎓 Acknowledgements

This project was built as a portfolio piece, and its foundation is built upon the incredible teachings of **Paul Hudson**.

A huge thank you to his **[100 Days of SwiftUI](https://www.hackingwithswift.com/100/swiftui)** course, which provides the knowledge and confidence to build complex, "premium-polish" apps like this one.

