//
//  ShowImageCell.swift
//  Gocamping
//
//  Created by 康 on 2023/8/23.
//

import UIKit

class ShowImageCell: UITableViewCell {

    @IBOutlet weak var showImageView: UIImageView!
    
    // MARK: - Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCellView()
        setupShowImageView()
    }
    
    // MARK: - UI setup
    private func setupShowImageView() {
        showImageView?.contentMode = .scaleAspectFill
        showImageView?.alpha = 0.8
        showImageView.layer.cornerRadius = 5
        showImageView.clipsToBounds = true
    }
    
    private func setupCellView() {
        self.backgroundColor = UIColor.brown.withAlphaComponent(0.2)
        self.selectionStyle = .none
    }
    
    // MARK: - Cell reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        showImageView.image = nil
    }

}
