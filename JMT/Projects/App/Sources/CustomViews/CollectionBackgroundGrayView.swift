//
//  CollectionBackgroundGrayView.swift
//  JMTeng
//
//  Created by PKW on 3/25/24.
//

import Foundation
import SnapKit
import UIKit

class CollectionBackgroundGrayView: UICollectionReusableView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = JMTengAsset.gray100.color
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
