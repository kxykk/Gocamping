//
//  ForgetpasswordVC.swift
//  Gocamping
//
//  Created by 康 on 2023/9/20.
//

import UIKit
import MessageUI

class ForgetpasswordVC: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var accountTextField: UITextField!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Button actions
    @IBAction func sendEmailBtnPressed(_ sender: Any) {
            guard let email = accountTextField.text, email != "" else {
                ShowMessageManager.shared.showToastGlobal( message: "請輸入正確的帳號(信箱)")
                disableTrace()
                return
            }
            UserNetworkManager.shared.searchUser(email: email) { result, statusCode, error in
                if let error = error {
                    ShowMessageManager.shared.showToastGlobal(message: "查無此帳號(信箱)")
                    return
                }
                if let result = result, let password = result.user?.password {
                    self.sendEmail(to: email, password: password)
                    NotificationCenter.default.post(name: NSNotification.Name("EmailSent"), object: nil)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    // MARK: - Send mail
    private func sendEmail(to email: String, password: String) {
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients([email])
                mail.setSubject("您的密碼")
                mail.setMessageBody("您的密碼是：\(password)", isHTML: false)

                present(mail, animated: true)
            } else {
                ShowMessageManager.shared.showToastGlobal(message: "無法發送電子郵件")
            }
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
        }
    
    //MARK: - End editing
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
