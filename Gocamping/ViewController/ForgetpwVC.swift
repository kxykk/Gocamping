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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func sendEmailBtnPressed(_ sender: Any) {
            guard let email = accountTextField.text, email != "" else {
                ShowMessageManager.shared.showToast(on: self, message: "請輸入正確的帳號(信箱)")
                return
            }
            NetworkManager.shared.searchUser(email: email) { result, statusCode, error in
                if let error = error {
                    ShowMessageManager.shared.showToast(on: self, message: "查無此帳號(信箱)")
                    return
                }
                if let result = result, let password = result.user?.password {
                    self.sendEmail(to: email, password: password)
                    NotificationCenter.default.post(name: NSNotification.Name("EmailSent"), object: nil)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    func sendEmail(to email: String, password: String) {
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients([email])
                mail.setSubject("您的密碼")
                mail.setMessageBody("您的密碼是：\(password)", isHTML: false)

                present(mail, animated: true)
            } else {
                // 顯示錯誤訊息
                ShowMessageManager.shared.showToast(on: self, message: "無法發送電子郵件")
            }
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
        }
    
}
