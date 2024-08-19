//
//  WeatherManager.swift
//  TripEase
//
//  Created by Naitik Ratilal Patel on 18/08/24.
//

import Foundation
import CoreLocation

// Delegate Methods to update UI in Controller
protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

// WeatherManager to manage API calls
struct WeatherManager {
    
    // URL
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=66f0ddc84aefee096d2cc1dea8ae6bbd&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    // generate URL based on city name
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    // generate URL based on user's location (Lat & Long)
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    // fetching weather data using URL session
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    // decoding user data
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            let windSpeed = decodedData.wind.speed
            let humidity = decodedData.main.humidity
            let weatherName = decodedData.weather[0].description
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp, windSpeed: windSpeed, humidity: humidity, weather: weatherName)
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
