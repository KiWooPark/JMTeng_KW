//
//  RestaurantPhotoCell.swift
//  JMTeng
//
//  Created by PKW on 3/10/24.
//

import Kingfisher
import UIKit

class RestaurantPhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var restaurantImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        restaurantImageView.image = nil
    }
    
    func setupData(imageUrl: String) {
        if let url = URL(string: imageUrl) {
            restaurantImageView.kf.setImage(with: url)
        }
    }
}
