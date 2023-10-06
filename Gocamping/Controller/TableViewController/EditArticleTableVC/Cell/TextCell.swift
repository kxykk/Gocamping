//
//  TextCell.swift
//  Gocamping
//
//  Created by 康 on 2023/8/7.
//

import UIKit

class TextCell: UITableViewCell {

    @IBOutlet weak var articleTextView: UITextView!

    // MARK: - Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        setupArticleTextView()
    }

    // MARK: - UI setup
    private func setupArticleTextView() {
        articleTextView.isScrollEnabled = false
    }
    
}
