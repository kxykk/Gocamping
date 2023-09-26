//
//  ShowMyCommentCell.swift
//  Gocamping
//
//  Created by 康 on 2023/8/22.
//

import UIKit

protocol ShowMyCommentCellDelegate: AnyObject {
    func didChangeCommentText(_ text: String)
}

class ShowMyCommentCell: UITableViewCell {
    
    @IBOutlet weak var showMyCommentTextView: UITextView!
    weak var delegate: ShowMyCommentCellDelegate?
    
    var placeholderText = "請在此輸入評論..."
    
    override func awakeFromNib() {
        super.awakeFromNib()

        showMyCommentTextView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        
        showMyCommentTextView.text = placeholderText
        showMyCommentTextView.textColor = UIColor.gray
        showMyCommentTextView.delegate = self
        
        let tapGesture = UIGestureRecognizer(target: self, action: #selector(handleTap))
        
    }
    
    @objc func handleTap() {
        showMyCommentTextView.becomeFirstResponder()
    }



}

extension ShowMyCommentCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        delegate?.didChangeCommentText(textView.text)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = placeholderText
            textView.textColor = UIColor.gray
        }
    }
    
}
