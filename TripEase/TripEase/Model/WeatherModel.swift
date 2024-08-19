//
//  WeatherModel.swift
//  TripEase
//
//  Created by Naitik Ratilal Patel on 18/08/24.
//

import Foundation

struct WeatherModel {
    let conditionId: Int
    let cityName: String
    let temperature: Double
    let windSpeed: Double
    let humidity: Double
    let weather: String
    
    var temperatureString: String {
        return String(format: "%.1f", temperature)
    }
    
    // system image name based on the condition Id fetched from the API
    var conditionName: String {
        switch conditionId {
        case 200...232:
            return "cloud.bolt"
        case 300...321:
            return "cloud.drizzle"
        case 500...531:
            return "cloud.rain"
        case 600...622:
            return "cloud.snow"
        case 701...781:
            return "cloud.fog"
        case 800:
            return "sun.max"
        case 801...804:
            return "cloud.bolt"
        default:
            return "cloud"
        }
    }
}
