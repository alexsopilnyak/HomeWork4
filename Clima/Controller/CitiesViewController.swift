//
//  CitiesCollectionViewController.swift
//  Clima
//
//  Created by Alexandr Sopilnyak on 18.01.2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit

private let dailyVCID = "WeatherViewController"

class CitiesViewController: UIViewController {
  private let defaultCities = ["Kyiv", "Kharkiv"]
  
  private var collectionView: UICollectionView!
  private var weatherManager = WeatherManager()
  private lazy var dataSource: UICollectionViewDiffableDataSource<Section, CityWeather> = {
    let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, CityWeather> { (cell, indexPath, item) in
      var content = cell.defaultContentConfiguration()
      content.text = item.cityName
      content.image = UIImage(systemName: item.conditionName)
      content.secondaryText = item.temperature.description
      
      cell.contentConfiguration = content
      cell.accessories = [.disclosureIndicator()]
      }
    
    return UICollectionViewDiffableDataSource<Section, CityWeather>(collectionView: collectionView) { (collectionView, indexPath, weatherModel) -> UICollectionViewCell? in
      collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: weatherModel)
    }
  }()
  
  private lazy var citiesWeather = [CityWeather]() {
    didSet {
      DispatchQueue.main.async { [weak self] in
        self?.applySnapshot()
      }
    }
  }
  
  private enum Section: CaseIterable {
    case main
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configLayout()
    applySnapshot()
    
    collectionView.delegate = self
    weatherManager.delegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    defaultCities.forEach {
      weatherManager.fetchDailyWeather(cityName: $0)
    }
  }
  
  private func configLayout() {
    let layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
    let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
    
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: listLayout)
    view.addSubview(collectionView)
    
    collectionView.backgroundColor = .systemTeal
    
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
      collectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0),
      collectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0)
    ])
   
    
  }
  
  private func applySnapshot(animatingDifferences: Bool = true) {
    var snapshot = NSDiffableDataSourceSnapshot<Section, CityWeather>()
    snapshot.appendSections(Section.allCases)
    snapshot.appendItems(citiesWeather)
    dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
  }
  
  
  @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    let alertController = UIAlertController(title: "New city", message: "Add new city", preferredStyle: .alert)
    
    let saveAction = UIAlertAction(title: "Save", style: .default) {[weak self] (alertAction) in
      let cityTextField = alertController.textFields![0] as UITextField
      if cityTextField.text != "" {
          self?.weatherManager.fetchDailyWeather(cityName: cityTextField.text!)
      }
    }
    
    saveAction.isEnabled = false
   
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
   
    alertController.addTextField { (textField) in
      textField.placeholder = "Please input city name"
    }
    
    
    NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: alertController.textFields![0], queue: OperationQueue.main) {[weak self] (notification) in
      guard let self = self else { return }
      let cityTextField = alertController.textFields![0]
      if let text = cityTextField.text {
        saveAction.isEnabled = self.isValidCity(name: text) && !text.isEmpty && !self.citiesWeather.contains{$0.cityName == text}
      }
    }
  
    alertController.addAction(saveAction)
    alertController.addAction(cancelAction)
    
    self.present(alertController, animated: true, completion: nil)
  }
  
  private func isValidCity(name: String) -> Bool {
    let cityRegEx = "^[a-zA-Z\u{0080}-\u{024F}\\s\\/\\-\\)\\(\\`\\.\\\"\\']*$"
    if let nameTest = NSPredicate(format:"SELF MATCHES %@", cityRegEx) as NSPredicate? {
      return nameTest.evaluate(with: name)
        }
        return false
  }
}

//MARK: - UICollectionViewDelegate

extension CitiesViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
   let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(identifier: dailyVCID) as! WeatherViewController
    vc.cityWeather = citiesWeather[indexPath.row]
    self.present(vc, animated: true, completion: nil)
    collectionView.deselectItem(at: indexPath, animated: true)
    
  }
}

//MARK: - WeatherManagerDelegate

extension CitiesViewController: WeatherManagerDelegate {
  func didUpdateDailyWeather(_ weatherManager: WeatherManager, weather: CityWeather) {
    DispatchQueue.main.async {
      self.citiesWeather.append(weather)
    }
  }
  
  func didUpdateWetherForecast(_ weatherManager: WeatherManager, weatherForecast: [WeatherForecast]) {
  }
  
  func didFailWithError(error: Error!) {
    print(error.localizedDescription)
  }

}
