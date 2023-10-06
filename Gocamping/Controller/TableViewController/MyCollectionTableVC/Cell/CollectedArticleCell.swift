//
//  CollectedArticleCell.swift
//  Gocamping
//
//  Created by 康 on 2023/8/30.
//

import UIKit

class CollectedArticleCell: UITableViewCell {

    @IBOutlet weak var collectedArticleImage: UIImageView!
    @IBOutlet weak var editBtnPressed: UIButton!
    @IBOutlet weak var collectedArticleTitleLabel: UILabel!
    
    // MARK: - Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        setupArticleImage()
        setupArticleTItle()
    }
    
    // MARK: - UI setup
    private func setupArticleImage() {
        collectedArticleImage?.contentMode = .scaleAspectFill
        collectedArticleImage?.alpha = 0.8
        collectedArticleImage.layer.cornerRadius = 10
        collectedArticleImage.clipsToBounds = true
    }
    
    private func setupArticleTItle() {
        collectedArticleTitleLabel.font = UIFont.boldSystemFont(ofSize: 24)
    }

    // MARK: - Configure button
    func configureButton(isHidden: Bool) {
        editBtnPressed.isHidden = isHidden
    }

}
