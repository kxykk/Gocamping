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
    
    // MARK: - Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    private func setupcommentTextView() {
        commentTextView.layer.cornerRadius = 10
        commentTextView.clipsToBounds = true
        commentTextView.shadow()
    }
    
    // MARK: - Cell reuse
    override func prepareForReuse() {
        editCommentBtnPressed.isHidden = true
    }
    
}
