//
//  WeatherManager.swift
//  Clima
//
//  Created by Alexandr Sopilnyak on 10.07.2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
  func didUpdateDailyWeather(_ weatherManager: WeatherManager, weather: CityWeather)
  func didUpdateWetherForecast(_ weatherManager: WeatherManager, weatherForecast: [WeatherForecast])
  func didFailWithError(error: Error!)
}



struct WeatherManager {
  let dailyWeatherURL = "https://api.openweathermap.org/data/2.5/weather?units=metric&appid=484f8b6d115fcc214dd51aa8f37ea476"
  let weatherForecastURL = "https://api.openweathermap.org/data/2.5/onecall?exclude=hourly,minutely,alerts&appid=484f8b6d115fcc214dd51aa8f37ea476&units=metric"
  
  var delegate: WeatherManagerDelegate?
  
  func fetchDailyWeather(cityName: String) {
    let urlString = "\(dailyWeatherURL)&q=\(cityName)"
    guard let urlWithAllowerCharacters = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
    performDailyRequest(with: urlWithAllowerCharacters)
  }
  
  func fetchDailyWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
    
    let urlString = "\(dailyWeatherURL)&lat=\(latitude)&lon=\(longitude)"
    performDailyRequest(with: urlString)
  }
  
  func fetchWeatherForecast(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
    let urlString = "\(weatherForecastURL)&lat=\(latitude)&lon=\(longitude)"
    performForecastRequest(with: urlString)
  }
  
  
  func performDailyRequest(with urlString: String) {
    if let url = URL(string: urlString) {
      
      let session = URLSession(configuration: .default)
      let task = session.dataTask(with: url) { (data, response, error) in
        if error != nil {
          self.delegate?.didFailWithError(error: error!)
          return
        }
        if let safeData = data {
          
          if let weather = self.parseDailyWeatherJSON(safeData) {
            self.delegate?.didUpdateDailyWeather(self, weather: weather)
          }
        }
      }
      task.resume()
    }
  }
  
  func performForecastRequest(with urlString: String) {
    if let url = URL(string: urlString) {
      
      let session = URLSession(configuration: .default)
      let task = session.dataTask(with: url) { (data, response, error) in
        if error != nil {
          self.delegate?.didFailWithError(error: error!)
          return
        }
        if let safeData = data {
          
          if let forecast = self.parseWeatherForecastJSON(safeData) {
            self.delegate?.didUpdateWetherForecast(self, weatherForecast: forecast)
          }
        }
      }
      task.resume()
    }
  }
  
  func parseDailyWeatherJSON(_ weatherData: Data) -> CityWeather? {
    
    let decoder = JSONDecoder()
    do {
      let decodedData =  try decoder.decode(CityWeatherData.self, from: weatherData)
      let id = decodedData.weather[0].id
      let temp = decodedData.main.temp
      let name = decodedData.name
      let feelsLike = decodedData.main.feelsLike
      let windSpeed = decodedData.wind.speed
      let coordinates = decodedData.coord
      
      
      let weather = CityWeather(condtitionId: id, cityName: name, temperature: temp, feelsLike: feelsLike, windSpeed: windSpeed, coordinates: coordinates)
      return weather
      
    } catch {
      delegate?.didFailWithError(error: error)
      return nil
    }
    
  }
  
  func parseWeatherForecastJSON (_ weatherData: Data) -> [WeatherForecast]? {
    var weatherForecast = [WeatherForecast]()
    let decoder = JSONDecoder()
    do {
      let decodedData =  try decoder.decode(WeatherForecastData.self, from: weatherData)
      decodedData.daily.forEach{
        let dateTimestamp = $0.date
        let conditionID = $0.weather[0].id
        let dayTemp = $0.temp.day
        let nightTemp = $0.temp.night
        
        let forecast = WeatherForecast(dateTimestamp: dateTimestamp, conditionID: conditionID, dayTemp: dayTemp, nightTemp: nightTemp)
        weatherForecast.append(forecast)
      }
      
      
      return weatherForecast
      
    } catch {
      delegate?.didFailWithError(error: error)
      return nil
    }
  }
  
  
}

