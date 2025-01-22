//
//  UITableView+Ext.swift
//  JMTeng
//
//  Created by PKW on 5/4/24.
//

import Foundation
import UIKit

extension UITableView {
    func setEmptyBackgroundView(str: String) {
        let background = UIView().then {
            $0.backgroundColor = .clear
        }
        
        let contentView = UIView().then {
            $0.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
            $0.tag = 999
        }
        
        let baseStackView = UIStackView().then {
            $0.axis = .vertical
            $0.distribution = .equalSpacing
            $0.alignment = .center
            $0.spacing = 16
        }
        
        let commentLabel = UILabel().then {
            $0.font = JMTengFontFamily.Pretendard.bold.font(size: 16)
            $0.textColor = JMTengAsset.gray300.color
            $0.numberOfLines = 0
            $0.tag = 998

            $0.setAttributedText(str: str, lineHeightMultiple: 1.25, kern: -0.32, alignment: .center)
        }
        
        let emptyImageView = UIImageView(image: JMTengAsset.emptyResult.image).then {
            $0.contentMode = .scaleAspectFit
        }
        
        baseStackView.addArrangedSubview(emptyImageView)
        baseStackView.addArrangedSubview(commentLabel)
        contentView.addSubview(baseStackView)
        background.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        baseStackView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        self.backgroundView = background
    }
    
    func adjustBackgroundViewHeight(keyboardHeight: CGFloat) {
      
        guard let backgroundView = self.backgroundView, let contentView = backgroundView.viewWithTag(999) else { return }
        
        contentView.snp.remakeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(self.bounds.height - keyboardHeight)
        }
    }
    
    func adjustCommentLabel(str: String) {
        guard let label = backgroundView?.viewWithTag(998) as? UILabel else { return }
        label.text = str
    }
    
    func removeEmptyBackgroundView() {
        self.backgroundView = nil
    }
}
