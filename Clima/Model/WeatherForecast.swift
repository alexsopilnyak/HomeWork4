//
//  WeatherForecast.swift
//  Clima
//
//  Created by Alexandr Sopilnyak on 19.01.2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation
struct WeatherForecast: Hashable {
  let dateTimestamp: Double
  let conditionID: Int
  let dayTemp: Double
  let nightTemp: Double
  
  var dayTempString: String {
    String(format: "%.1f", dayTemp)
  }
  
  var nightTempString: String {
    String(format: "%.1f", nightTemp)
  }
  
  var date: String {
    
      let date = Date(timeIntervalSince1970: dateTimestamp)
      let dateFormatter = DateFormatter()
      
      dateFormatter.dateFormat = "MMM d"
      return dateFormatter.string(from: date)
  }
  
  var conditionName: String {     //computed property
    switch conditionID {
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
