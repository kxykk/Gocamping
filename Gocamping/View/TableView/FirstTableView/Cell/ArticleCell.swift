//
//  ArticleCell.swift
//  Gocamping
//
//  Created by 康 on 2023/8/4.
//

import UIKit

class ArticleCell: UITableViewCell {

    @IBOutlet weak var articleLabel: UILabel!
    @IBOutlet weak var articleImage: UIImageView!

    var articleID: Int = 0

    // MARK: - Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    // MARK: - UI setup
    private func setupUI() {
        setupImageView()
        setupLabel()
    }

    private func setupImageView() {
        articleImage?.contentMode = .scaleAspectFill
        articleImage?.alpha = 0.8
        articleImage.layer.cornerRadius = 10
        articleImage.clipsToBounds = true
    }

    private func setupLabel() {
        articleLabel.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        articleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        articleLabel.textColor = UIColor.white
        articleLabel.clipsToBounds = true
        updateLabelAppearance()
    }

    private func updateLabelAppearance() {
        let attributedString = NSMutableAttributedString(string: articleLabel.text ?? "")
        attributedString.addAttribute(NSAttributedString.Key.kern, value: 1.2, range: NSMakeRange(0, attributedString.length))
        articleLabel.attributedText = attributedString
    }

    // MARK: - Cell reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        articleImage.image = nil
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLabelMask()
    }

    private func updateLabelMask() {
        let path = UIBezierPath(roundedRect: articleLabel.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 10, height: 10))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = articleLabel.bounds
        maskLayer.path = path.cgPath
        articleLabel.layer.mask = maskLayer
    }

}
