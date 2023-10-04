//
//  UIView+NoResultLabel.swift
//  Gocamping
//
//  Created by 康 on 2023/10/4.
//

import UIKit

extension UIView {
    func addNoResultsLabel(withText text: String) -> UILabel {
        let noResultsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 50))
        noResultsLabel.text = text
        noResultsLabel.textAlignment = .center
        noResultsLabel.textColor = .gray
        noResultsLabel.isHidden = true
        self.addSubview(noResultsLabel)
        self.bringSubviewToFront(noResultsLabel)
        return noResultsLabel
    }
}
