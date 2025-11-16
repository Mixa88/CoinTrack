//
//  Double+Extensions.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 07.11.2025.
//


import Foundation

extension Double {
    
    /// Converts a Double into a Currency String with 2-6 decimal places.
    /// ```
    /// Example: 1234.56 -> "$1,234.56"
    /// ```
    func toCurrencyString() -> String {
        // Use 2-6 decimal places for crypto
        return self.formatted(.currency(code: "usd").precision(.fractionLength(2...6)))
    }
    
    /// Converts a Double into a Percent String with 2 decimal places.
    /// ```
    /// Example: 1.23 -> "1.23%"
    /// ```
    func toPercentString() -> String {
        // CoinGecko already gives us 1.23 for 1.23%
        return self.formatted(.percent.precision(.fractionLength(2)))
    }
    
    /// Converts a large Double into a human-readable string (e.g., "$1.2T")
    /// ```
    /// Example: 1234567890123.0 -> "$1.23T"
    /// ```
    func toFormattedString() -> String {
        let number = abs(self)
        let sign = (self < 0) ? "-" : ""

        switch number {
        case 1_000_000_000_000...: // Trillions
            let formatted = number / 1_000_000_000_000
            return "\(sign)\(formatted.formatted(.number.precision(.fractionLength(2))))T"
        case 1_000_000_000...: // Billions
            let formatted = number / 1_000_000_000
            return "\(sign)\(formatted.formatted(.number.precision(.fractionLength(2))))B"
        case 1_000_000...: // Millions
            let formatted = number / 1_000_000
            return "\(sign)\(formatted.formatted(.number.precision(.fractionLength(2))))M"
        case 0...:
            return self.formatted(.number.precision(.fractionLength(2)))
        default:
            return "\(sign)\(self.formatted(.number.precision(.fractionLength(2))))"
        }
    }
    
    func toDominanceString() -> String {
        return self.formatted(.number.precision(.fractionLength(2))) + "%"
    }
}

extension String {
    
    /// Removes HTML tags from a string.
    /// ```
    /// Example: "<p>Hello</p> <strong>World</strong>" -> "Hello World"
    /// ```
    func stripHTML() -> String {
        // This is a simple regex to find and replace
        // anything that looks like an HTML tag (<...>)
        // and replace it with a space (to avoid "HelloWord").
        return self.replacingOccurrences(of: "<[^>]+>",
                                         with: " ", // Use a space
                                         options: .regularExpression,
                                         range: nil)
                   // Also clean up extra whitespace
                   .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
