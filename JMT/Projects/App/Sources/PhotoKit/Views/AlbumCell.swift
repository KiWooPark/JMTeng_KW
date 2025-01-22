//
//  AlbumCell.swift
//  App
//
//  Created by PKW on 2024/01/11.
//

import UIKit

class AlbumCell: UITableViewCell {
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var albumCountLabel: UILabel!
        
    override func prepareForReuse() {
        super.prepareForReuse()
        
        prepare(info: nil)
    }
    
    func prepare(info: AlbumInfo?) {
        albumImageView.image = info?.thumbnail
        albumTitleLabel.text = info?.title
        albumCountLabel.text = "\(info?.numberOfItems ?? 0)"
    }
}
