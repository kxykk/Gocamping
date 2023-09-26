//
//  ShowUserCell.swift
//  Gocamping
//
//  Created by 康 on 2023/8/22.
//

import UIKit

class ShowUserCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    
        userNameTextLabel.font = UIFont.boldSystemFont(ofSize: 20)
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {

        // Configure the view for the selected state
    }

}
