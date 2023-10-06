//
//  UserCell.swift
//  Gocamping
//
//  Created by 康 on 2023/8/4.
//

import UIKit

class UserCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    // MARK: - Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        userNameLabel()
    }
    
    // MARK: - UI setup
    private func userNameLabel() {
        usernameLabel?.font = UIFont.boldSystemFont(ofSize: 20)
    }
    
}

