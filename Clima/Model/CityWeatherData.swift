//
//  WeatherData.swift
//  Clima
//
//  Created by Alexandr Sopilnyak on 10.07.2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

struct CityWeatherData: Codable {
  let name: String
  let main: Main
  let weather: [Weather]
  let coord: Coordinates
  let wind: Wind
}

struct Main:Codable {
  let temp: Double
  let feelsLike: Double
  
  enum CodingKeys: String, CodingKey {
    case temp
    case feelsLike = "feels_like"
  }
}

struct Weather: Codable {
  let id: Int
}

struct Wind: Codable {
  let speed: Double
}

struct Coordinates: Codable, Hashable {
  let lon: Double
  let lat: Double
}

