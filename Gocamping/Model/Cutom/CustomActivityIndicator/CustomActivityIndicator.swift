//
//  CustomActivityIndicator.swift
//  Gocamping
//
//  Created by 康 on 2023/10/6.
//

import UIKit

class CustomActivityIndicator: UIActivityIndicatorView {

   
    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    private func setup() {
        self.style = .large
        self.hidesWhenStopped = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    func addToView(_ superview: UIView) {
        superview.addSubview(self)

        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            self.centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        ])
    }
}
