//
//  PlaceholderCollectionViewCell.swift
//  JMTeng
//
//  Created by PKW on 2024/02/28.
//

import SkeletonView
import UIKit

class PlaceholderCollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        isSkeletonable = true
    }
}
