//
//  CollectedArticleCell.swift
//  Gocamping
//
//  Created by 康 on 2023/8/30.
//

import UIKit

class CollectedArticleCell: UITableViewCell {

    @IBOutlet weak var collectedArticleImage: UIImageView!
    @IBOutlet weak var collectedArticleTitleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        collectedArticleImage?.contentMode = .scaleAspectFill
        collectedArticleImage?.alpha = 0.8
        collectedArticleImage.layer.cornerRadius = 10
        collectedArticleImage.clipsToBounds = true
        
        collectedArticleTitleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
