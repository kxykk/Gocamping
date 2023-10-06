//
//  NoticeCell.swift
//  Gocamping
//
//  Created by 康 on 2023/8/7.
//

import UIKit

class NotifyCell: UITableViewCell {

    @IBOutlet weak var noticeTime: UILabel!
    @IBOutlet weak var noticeMessage: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
