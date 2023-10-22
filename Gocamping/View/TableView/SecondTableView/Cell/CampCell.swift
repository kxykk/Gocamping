//
//  CampCell.swift
//  Gocamping
//
//  Created by 康 on 2023/8/6.
//

import UIKit

class CampCell: UITableViewCell {

    @IBOutlet weak var campLocation: UILabel!
    @IBOutlet weak var campName: UILabel!
    @IBOutlet weak var campImage: UIImageView!
    
    // MARK: - Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        setupImageView()
    }
    
    // MARK: - UI setup
    private func setupImageView() {
        campImage.contentMode = .scaleAspectFill
        campImage.alpha = 0.8
        campImage.layer.cornerRadius = 10
        campImage.clipsToBounds = true
    }
    
    // MARK: - Cell reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        campImage.image = nil
    }

}
