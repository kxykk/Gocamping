//
//  ShowImageCell.swift
//  Gocamping
//
//  Created by 康 on 2023/8/23.
//

import UIKit

class ShowImageCell: UITableViewCell {

    @IBOutlet weak var showImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        showImageView?.contentMode = .scaleAspectFill
        showImageView?.alpha = 0.8
        
        showImageView.layer.cornerRadius = 5
        showImageView.clipsToBounds = true
        
        self.backgroundColor = UIColor.brown.withAlphaComponent(0.2)

        self.selectionStyle = .none
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        showImageView.image = nil
    }



}
