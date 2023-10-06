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
    
    // MARK: - Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUserNameTextLabel()
    }
    
    // MARK: - UI setup
    private func setupUserNameTextLabel() {
        userNameTextLabel.font = UIFont.boldSystemFont(ofSize: 20)
    }

}
