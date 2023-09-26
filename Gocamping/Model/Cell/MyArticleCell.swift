//
//  MyArticleCell.swift
//  Gocamping
//
//  Created by 康 on 2023/8/7.
//

import UIKit



class MyArticleCell: UITableViewCell {

    @IBOutlet weak var myArticleImage: UIImageView!
    
    @IBOutlet weak var myArticleTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        myArticleImage?.contentMode = .scaleAspectFill
        myArticleImage?.alpha = 0.8
        myArticleImage.layer.cornerRadius = 10
        myArticleImage.clipsToBounds = true
        
        myArticleTitle.font = UIFont.boldSystemFont(ofSize: 24)
        
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
