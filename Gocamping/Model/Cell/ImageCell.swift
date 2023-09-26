//
//  ImageCell.swift
//  Gocamping
//
//  Created by 康 on 2023/8/7.
//

import UIKit

class ImageCell: UITableViewCell {
    

    @IBOutlet weak var articleImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        articleImageView?.contentMode = .scaleAspectFill

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
