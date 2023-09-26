//
//  CampCell.swift
//  Gocamping
//
//  Created by 康 on 2023/8/6.
//

import UIKit

class CampCell: UITableViewCell {

    @IBOutlet weak var campDistance: UILabel!
    @IBOutlet weak var campLocation: UILabel!
    @IBOutlet weak var campName: UILabel!
    @IBOutlet weak var campImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        campImage.contentMode = .scaleAspectFill
        campImage.alpha = 0.8
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        campImage.image = nil
    }

}
