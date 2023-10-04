//
//  UITableVIew+shadow.swift
//  Gocamping
//
//  Created by 康 on 2023/10/4.
//

import UIKit

extension UITableView {
    func addShadow() {
        guard let superview = self.superview else { return }

        // Create shadow container
        let shadowContainer = UIView()
        shadowContainer.translatesAutoresizingMaskIntoConstraints = false
        shadowContainer.layer.shadowColor = UIColor.black.cgColor
        shadowContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        shadowContainer.layer.shadowOpacity = 0.3
        shadowContainer.layer.shadowRadius = 4.0
        shadowContainer.layer.masksToBounds = false
        shadowContainer.backgroundColor = .clear

        // Configure self
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false

        // Add shadow container to superview
        superview.addSubview(shadowContainer)

        // Move self to shadow container
        self.removeFromSuperview()
        shadowContainer.addSubview(self)

        // Set shadowContainer constraints relative to superview
        NSLayoutConstraint.activate([
            shadowContainer.topAnchor.constraint(equalTo: superview.topAnchor),
            shadowContainer.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            shadowContainer.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            shadowContainer.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
        ])

        // Make sure the shadow container and the table view have the same size and position
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: shadowContainer.topAnchor),
            self.bottomAnchor.constraint(equalTo: shadowContainer.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: shadowContainer.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: shadowContainer.trailingAnchor)
        ])
    }
}


