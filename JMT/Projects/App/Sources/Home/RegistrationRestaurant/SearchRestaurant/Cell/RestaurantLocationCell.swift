//
//  RestaurantLocationCell.swift
//  JMTeng
//
//  Created by PKW on 2024/02/20.
//

import UIKit

class RestaurantLocationCell: UITableViewCell {

    @IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    func setupData(viewModel: SearchRestaurantsLocationModel?) {
        restaurantNameLabel.text = viewModel?.placeName ?? ""
        distanceLabel.text = (viewModel?.distance ?? 0).distanceWithUnit()
        addressLabel.text = viewModel?.addressName ?? ""
    }
}
