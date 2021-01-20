//
//  WeatherModel.swift
//  Clima
//
//  Created by Alexandr Sopilnyak on 14.07.2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

struct CityWeather: Hashable {
    
    let condtitionId: Int
    let cityName: String
    let temperature: Double
    let feelsLike: Double
    let windSpeed: Double
    let coordinates: Coordinates
  
  var feelsLikeString: String {
    String(format: "%.1f", feelsLike)
  }
  
  var windSpeedString: String {
    String(format: "%.1f", windSpeed)
  }
  
    
    var temperatureString: String {
         String(format: "%.1f", temperature)
    }
    
    var conditionName: String {    
        switch condtitionId {
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
