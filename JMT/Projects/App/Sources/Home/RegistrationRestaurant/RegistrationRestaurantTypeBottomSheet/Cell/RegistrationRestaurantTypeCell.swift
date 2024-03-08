//
//  RegistrationRestaurantTypeCell.swift
//  JMTeng
//
//  Created by PKW on 2024/02/05.
//

import UIKit

class RegistrationRestaurantTypeCell: UITableViewCell {

    @IBOutlet weak var typeContrainerView: UIView!
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var typeNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        typeContrainerView.layer.cornerRadius = 8
        typeContrainerView.layer.borderWidth = 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    func setupUI(isSelected: Bool) {
        typeContrainerView.layer.borderColor = isSelected ? JMTengAsset.main500.color.cgColor : JMTengAsset.gray100.color.cgColor
    }
}