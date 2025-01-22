//
//  RestaurantInfoCell.swift
//  JMTeng
//
//  Created by PKW on 3/15/24.
//

import Kingfisher
import UIKit

class RestaurantInfoCell: UICollectionViewCell {
    
    @IBOutlet weak var restaurantProfileImageView: UIImageView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var restaurantNameLabel: UILabel!
    
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        restaurantProfileImageView.layer.cornerRadius = 8
        userProfileImageView.layer.cornerRadius = 10
        categoryView.layer.cornerRadius = 4
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        restaurantProfileImageView.image = nil
        categoryLabel.text = nil
        groupNameLabel.text = nil
        restaurantNameLabel.text = nil
        userProfileImageView.image = nil
        userNameLabel.text = nil
    }
    
    func setupRestaurantInfoData<T>(data: T) {
        if let restaurantData = data as? SearchRestaurantsModel {
            restaurantProfileImageView.loadImage(urlString: restaurantData.restaurantImageUrl, defaultImage: JMTengAsset.resultEmptyImage.image)
            userProfileImageView.loadImage(urlString: restaurantData.userProfileImageUrl, defaultImage: JMTengAsset.defaultProfileImage.image)
            categoryLabel.text = restaurantData.category
            groupNameLabel.text = restaurantData.groupName
            restaurantNameLabel.text = restaurantData.name
            userNameLabel.text = restaurantData.userNickName
        } else if let outBoundRestaurantData = data as? OutBoundRestaurantsModel {
            restaurantProfileImageView.loadImage(urlString: outBoundRestaurantData.restaurantImageUrl, defaultImage: JMTengAsset.resultEmptyImage.image)
            userProfileImageView.loadImage(urlString: outBoundRestaurantData.userProfileImageUrl, defaultImage: JMTengAsset.defaultProfileImage.image)
            categoryLabel.text = outBoundRestaurantData.category
            groupNameLabel.text = outBoundRestaurantData.groupName
            restaurantNameLabel.text = outBoundRestaurantData.name
            userNameLabel.text = outBoundRestaurantData.userNickName
        }
    }
}
