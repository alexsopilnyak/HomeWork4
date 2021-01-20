//
//  WeatherViewController.swift
//  Clima
//
//  Created by Alexandr Sopilnyak on 10.07.2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
  
  private let cellID = "dailyCell"
  private let locationManager = CLLocationManager()
  private var weatherManager = WeatherManager()
  private var forecast: [WeatherForecast]? {
    didSet {
      tableView.reloadData()
    }
  }
  
  var cityWeather: CityWeather?
  
  @IBOutlet private weak var tableView: UITableView!
  @IBOutlet private weak var conditionImageView: UIImageView!
  @IBOutlet private weak var temperatureLabel: UILabel!
  @IBOutlet private weak var cityLabel: UILabel!
  @IBOutlet private weak var searchTextField: UITextField!
  @IBOutlet private weak var feelsLikeLabel: UILabel!
  @IBOutlet private weak var windSpeedLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    weatherManager.delegate = self
    setup()
   
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if let cityWeather = cityWeather {
      cityLabel.text = cityWeather.cityName
      conditionImageView.image = UIImage(systemName: cityWeather.conditionName)
      temperatureLabel.text = cityWeather.temperatureString
      feelsLikeLabel.text = cityWeather.feelsLikeString
      windSpeedLabel.text = cityWeather.windSpeedString
      
      let lon = cityWeather.coordinates.lon
      let lat = cityWeather.coordinates.lat
      
      weatherManager.fetchWeatherForecast(latitude: lat, longitude: lon)
      
    }
  }
  
  private func setup() {
    searchTextField.delegate = self
    weatherManager.delegate = self
    locationManager.delegate = self
    tableView.delegate = self
    tableView.dataSource = self
    //locationManager.requestWhenInUseAuthorization() // for automatically detection location
    //locationManager.requestLocation()
  }
}

//MARK:- UITableViewDelegate

extension WeatherViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
  }
  
}

//MARK:- UITableViewDelegate

extension WeatherViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 4
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! DailyTableViewCell
    if let forecast = forecast {
      let dayForecats = forecast[indexPath.row + 1]
      cell.conditionImage.image = UIImage(systemName: dayForecats.conditionName)
      cell.day.text = dayForecats.date
      cell.dayTemperature.text = dayForecats.dayTempString
      cell.nightTemperature.text = dayForecats.nightTempString
      cell.backgroundColor = .clear
    }
    
    return cell
  }
  
}

//MARK: -UITextFieldDelegate
extension WeatherViewController: UITextFieldDelegate {
  
  @IBAction func searchPressed(_ sender: UIButton) {
    print(searchTextField.text!)
    searchTextField.endEditing(true)
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    print(textField.text!)
    textField.endEditing(true)
    return true
  }
  
  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    if textField.text != "" {
      return true
    } else {
      textField.placeholder = "Type something"
      return false
    }
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    //Use searchTextField.text to get weather for the city
    if let city = textField.text {
      weatherManager.fetchDailyWeather(cityName: city)

    }
    textField.text = ""
  }
}


//MARK: - WeatherManagerDelegate
extension WeatherViewController: WeatherManagerDelegate {
  
  
  func didUpdateWetherForecast(_ weatherManager: WeatherManager, weatherForecast: [WeatherForecast]) {
    DispatchQueue.main.async {
      self.forecast = weatherForecast
      
    }
    
  }
  
  
  func didUpdateDailyWeather(_ weatherManager: WeatherManager, weather: CityWeather) {
    DispatchQueue.main.async {
      self.temperatureLabel.text = weather.temperatureString
      self.conditionImageView.image = UIImage(systemName: weather.conditionName)
      self.cityLabel.text = weather.cityName
      self.feelsLikeLabel.text = weather.feelsLikeString
      self.windSpeedLabel.text = weather.windSpeedString
      
      weatherManager.fetchWeatherForecast(latitude: weather.coordinates.lat, longitude: weather.coordinates.lon)
      
    }
  }
  
  func didFailWithError(error: Error!) {
    print(error.localizedDescription)
  }
}

//MARK: -  CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let locValue = manager.location?.coordinate {
      print("\(locValue.latitude) \(locValue.longitude)")
    }
    
    if let location = locations.last {
      locationManager.stopUpdatingLocation()
      let lat = location.coordinate.latitude
      let lon = location.coordinate.longitude
      weatherManager.fetchDailyWeather(latitude: lat, longitude: lon)
      weatherManager.fetchWeatherForecast(latitude: lat, longitude: lon)
    }
  }
  
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
  
  @IBAction func locationPressed(_ sender: UIButton) {
    locationManager.requestLocation()
  }
  
}





