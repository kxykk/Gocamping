//
//  TitleCell.swift
//  Gocamping
//
//  Created by 康 on 2023/8/4.
//

import UIKit


class ArticleCell: UITableViewCell {

    @IBOutlet weak var articleLabel: UILabel!
    @IBOutlet weak var articleImage: UIImageView!
    
    
    var articleID: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        articleImage?.contentMode = .scaleAspectFill
        articleImage?.alpha = 0.8
        articleImage.layer.cornerRadius = 10
        articleImage.clipsToBounds = true
        
            
        articleLabel.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        articleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        articleLabel.textColor = UIColor.white
        //articleLabel.layer.cornerRadius = 10
        articleLabel.clipsToBounds = true
        
        let path = UIBezierPath(roundedRect:articleLabel.bounds, byRoundingCorners:[.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 10, height: 10))
            let maskLayer = CAShapeLayer()
            maskLayer.frame = articleLabel.bounds
            maskLayer.path = path.cgPath
            articleLabel.layer.mask = maskLayer
        
        let attributedString = NSMutableAttributedString(string: articleLabel.text ?? "")
        attributedString.addAttribute(NSAttributedString.Key.kern, value: 1.2, range: NSMakeRange(0, attributedString.length))
        articleLabel.attributedText = attributedString
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        articleImage.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
