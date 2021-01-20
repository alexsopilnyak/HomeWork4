//
//  WeatherForecastData.swift
//  Clima
//
//  Created by Alexandr Sopilnyak on 19.01.2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation

struct WeatherForecastData: Codable {
  let daily: [DailyForecast]
}

struct DailyForecast: Codable {
  let date: Double
  let temp: Temperature
  let weather: [Weather]
  
  enum CodingKeys: String, CodingKey {
    case date = "dt"
    case temp
    case weather
  }
}

struct Temperature: Codable {
  let day: Double
  let night: Double
}
