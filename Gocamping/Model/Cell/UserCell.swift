//
//  UserCell.swift
//  Gocamping
//
//  Created by 康 on 2023/8/4.
//

import UIKit

class UserCell: UITableViewCell {
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        userName?.font = UIFont.boldSystemFont(ofSize: 20)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

