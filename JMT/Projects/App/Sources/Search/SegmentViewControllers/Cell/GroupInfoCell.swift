//
//  GroupInfoCell.swift
//  JMTeng
//
//  Created by PKW on 3/15/24.
//

import Kingfisher
import UIKit

class GroupInfoCell: UICollectionViewCell {
    
    @IBOutlet weak var groupProfileImageView: UIImageView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var restaurantCountLabel: UILabel!
    @IBOutlet weak var groupIntroduceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        groupProfileImageView.layer.cornerRadius = 8
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        groupProfileImageView.image = nil
        groupNameLabel.text = nil
        memberCountLabel.text = nil
        restaurantCountLabel.text = nil
        groupIntroduceLabel.text = nil
    }
    
    func setupData(groupData: SearchGroupItems?) {
        if let data = groupData {
            groupProfileImageView.loadImage(urlString: data.groupProfileImageUrl, defaultImage: JMTengAsset.defaultProfileImage.image)
            groupNameLabel.text = data.groupName
            memberCountLabel.text = "멤버 \(data.memberCnt)"
            restaurantCountLabel.text = "맛집 \(data.restaurantCnt)"
            groupIntroduceLabel.text = data.groupIntroduce
        }
    }
}
