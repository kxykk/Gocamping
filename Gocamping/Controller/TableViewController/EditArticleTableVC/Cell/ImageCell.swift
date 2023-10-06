//
//  ImageCell.swift
//  Gocamping
//
//  Created by 康 on 2023/8/7.
//

import UIKit

class ImageCell: UITableViewCell {
    
    @IBOutlet weak var articleImageView: UIImageView!
    
    // MARK: - Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        setupArticleImageView()
    }

    // MARK: - UI setup
    private func setupArticleImageView() {
        articleImageView?.contentMode = .scaleAspectFill
    }
    
}
