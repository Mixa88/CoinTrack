//
//  CoinDetail.swift
//  CoinTrack
//
//  Created by Михайло Тихонов on 06.11.2025.
//


import Foundation

// This struct will hold all the chart data
// we get back from the CoinGecko API.
struct CoinDetail: Codable {
    // "prices" is an array of [Timestamp, Price]
    let prices: [[Double]]
}
