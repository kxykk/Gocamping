//
//  ShowTextCell.swift
//  Gocamping
//
//  Created by 康 on 2023/8/22.
//

import UIKit

class ShowTextCell: UITableViewCell {

    @IBOutlet weak var showTextView: UITextView!
    
    // MARK: - Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        setupShowTextView()
    }
    
    // MARK: - UI setup
    private func setupShowTextView() {
        showTextView.textColor = UIColor.gray
        showTextView.font = UIFont.boldSystemFont(ofSize: 18)
        showTextView.backgroundColor = UIColor.brown.withAlphaComponent(0.2)
    }
}
