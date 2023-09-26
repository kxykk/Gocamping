//
//  TextCell.swift
//  Gocamping
//
//  Created by 康 on 2023/8/7.
//

import UIKit

class TextCell: UITableViewCell {

    @IBOutlet weak var articleTextView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        articleTextView.isScrollEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
