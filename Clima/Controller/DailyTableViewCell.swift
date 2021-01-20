//
//  DailyTableViewCell.swift
//  Clima
//
//  Created by Alexandr Sopilnyak on 19.01.2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit

class DailyTableViewCell: UITableViewCell {

  override class func awakeFromNib() {
    super.awakeFromNib()
  }
  
  @IBOutlet weak var day: UILabel!
  @IBOutlet weak var conditionImage: UIImageView!
  @IBOutlet weak var dayTemperature: UILabel!
  @IBOutlet weak var nightTemperature: UILabel!
  
  
}
