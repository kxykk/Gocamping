//
//  ShowTextCell.swift
//  Gocamping
//
//  Created by 康 on 2023/8/22.
//

import UIKit

class ShowTextCell: UITableViewCell {

    @IBOutlet weak var showTextView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        showTextView.textColor = UIColor.gray
        showTextView.font = UIFont.boldSystemFont(ofSize: 18)
        
        showTextView.backgroundColor = UIColor.brown.withAlphaComponent(0.2)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {

        // Configure the view for the selected state
    }

}
