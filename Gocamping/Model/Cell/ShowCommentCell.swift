//
//  ShowCommentCell.swift
//  Gocamping
//
//  Created by 康 on 2023/8/22.
//

import UIKit

class ShowCommentCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var editCommentBtnPressed: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    override func prepareForReuse() {
        editCommentBtnPressed.isHidden = true
    }


}
