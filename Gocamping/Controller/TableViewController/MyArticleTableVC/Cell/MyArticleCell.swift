//
//  MyArticleCell.swift
//  Gocamping
//
//  Created by 康 on 2023/8/7.
//

import UIKit



class MyArticleCell: UITableViewCell {

    @IBOutlet weak var myArticleImage: UIImageView!
    @IBOutlet weak var myArticleTitle: UILabel!
    @IBOutlet weak var editBtnPressed: UIButton!
    
    // MARK: - Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        setupArticleImage()
        setupArticleTitle()
    }
    
    // MARK: - UI setup
    private func setupArticleImage() {
        myArticleImage?.contentMode = .scaleAspectFill
        myArticleImage?.alpha = 0.8
        myArticleImage.layer.cornerRadius = 10
        myArticleImage.clipsToBounds = true
    }
    
    private func setupArticleTitle() {
        myArticleTitle.font = UIFont.boldSystemFont(ofSize: 24)
    }
    
    // MARK: - Configure button
    func configureButton(isHidden: Bool) {
        editBtnPressed.isHidden = isHidden
    }
}
