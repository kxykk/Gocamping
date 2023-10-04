//
//  FifthViewController.swift
//  Gocamping
//
//  Created by 康 on 2023/7/24.
//

import UIKit
import MessageUI

protocol FifthVCDelegate: AnyObject {
    func didLogoutSuccessfully()
    func didDeleteUserSuccessfully()
}
class FifthViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var deleteAccountBtnPressed: UIButton!
    @IBOutlet weak var sharedBtnPressed: UIButton!
    @IBOutlet weak var reportBtnPressed: UIButton!
    @IBOutlet weak var logoutBtnPressed: UIButton!
    
    @IBOutlet weak var myEmailBtnPressed: UIButton!
    weak var fifthVCDelegate: FifthVCDelegate?
    
    let email = "gocamping919@gmail.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        
        
        reportBtnPressed.setImage(UIImage(named: "problems"), for: .normal)
        reportBtnPressed.setTitle("  回報問題", for: .normal)
        reportBtnPressed.setTitleColor(UIColor.systemBlue.withAlphaComponent(0.8), for: .normal)
        reportBtnPressed.imageView?.contentMode = .scaleAspectFill
        
        sharedBtnPressed.setImage(UIImage(named: "share"), for: .normal)
        sharedBtnPressed.setTitle("  分享App", for: .normal)
        sharedBtnPressed.setTitleColor(.blue, for: .normal)
        sharedBtnPressed.imageView?.contentMode = .scaleAspectFill
        sharedBtnPressed.isHidden = true
        
        deleteAccountBtnPressed.setImage(UIImage(named: "delete"), for: .normal)
        deleteAccountBtnPressed.setTitle("  刪除帳號", for: .normal)
        deleteAccountBtnPressed.setTitleColor(.red, for: .normal)
        deleteAccountBtnPressed.imageView?.contentMode = .scaleAspectFill
        
        logoutBtnPressed.setImage(UIImage(named: "logout"), for: .normal)
        logoutBtnPressed.setTitle("  登出", for: .normal)
        logoutBtnPressed.setTitleColor(UIColor.systemBlue.withAlphaComponent(0.8), for: .normal)
        logoutBtnPressed.imageView?.contentMode = .scaleAspectFill
        
        let title = "連絡信箱: \n\(email)"
        let styledTitle = styleButtonText(title: title)
        myEmailBtnPressed.setImage(UIImage(named: "icon"), for: .normal)
        myEmailBtnPressed.setAttributedTitle(styledTitle, for: .normal)
        myEmailBtnPressed.setTitleColor(UIColor.black, for: .normal)
        myEmailBtnPressed.imageView?.contentMode = .scaleAspectFill
        myEmailBtnPressed.contentHorizontalAlignment = .left
        

        
        styleButton(reportBtnPressed)
        styleButton(sharedBtnPressed)
        styleButton(deleteAccountBtnPressed)
        styleButton(logoutBtnPressed)

        
        
    }
    
    
    @IBAction func logoutBtnPressed(_ sender: Any) {
        let userID = UserDefaults.standard.integer(forKey: userIDKey)
        print("Current User ID: \(userID)")
        if userID == 0 {
            print("您尚未登入")
            ShowMessageManager.shared.showToastGlobal(message: "您尚未登入")
            return
        } else {
            print("登出")
            UserDefaults.standard.set(0, forKey: userIDKey)
            UserDefaults.standard.set("", forKey: userNameKey)
            UserDefaults.standard.set("", forKey: introductionKey)
            UserDefaults.standard.set("", forKey: imageURLKey)
            ArticleManager.shared.myArticle = []
            ArticleManager.shared.myCollectedArticle = []
            
            fifthVCDelegate?.didLogoutSuccessfully()
            NotificationCenter.default.post(name: Notification.Name("UserDidLogout"), object: nil)
            
            if let tabBarController = self.tabBarController as? CustomTabBarController {
                tabBarController.selectedIndex = 0
            }
        }
    }
    @IBAction func reportBtnPressed(_ sender: Any) {
        
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            mailComposeViewController.setToRecipients([email])
            mailComposeViewController.setSubject("回報問題")
            mailComposeViewController.setMessageBody("請在這裡描述您的問題...", isHTML: false)
            
            present(mailComposeViewController, animated: true, completion: nil)
        } else {
            let message = "此設備不能發送信件"
            ShowMessageManager.shared.showToastGlobal(message: message)
        }
        
    }
    
    @IBAction func deleteAccountBtnPressed(_ sender: Any) {
        
        let userID = UserDefaults.standard.integer(forKey: userIDKey)
        if userID == 0 {
            ShowMessageManager.shared.showToastGlobal(message: "您尚未登入!")
        } else {
            
            ShowMessageManager.shared.showDeleteAlert(on: self, title: "刪除帳號", message: "確定刪除帳號嗎？") {
                NetworkManager.shared.deleteUser(userID: userID) { result, statusCode, error in
                    if let error = error {
                        assertionFailure("Delete user error: \(error)")
                        return
                    }
                    // Reset Userdefault
                    UserDefaults.standard.set(0, forKey: userIDKey)
                    UserDefaults.standard.set("", forKey: userNameKey)
                    UserDefaults.standard.set("", forKey: introductionKey)
                    UserDefaults.standard.set("", forKey: imageURLKey)
                    ArticleManager.shared.myArticle = []
                    ArticleManager.shared.myCollectedArticle = []
                    
                    // Guide to the first page
                    if let tabBarController = self.tabBarController as? CustomTabBarController {
                        tabBarController.selectedIndex = 0
                    }
                    
                    // Notification
                    NotificationCenter.default.post(name: Notification.Name("UserDidDelete"), object: nil)
                    
                }
            }
        }
    }
    
    @IBAction func myEmailBtnPressed(_ sender: Any) {
        
    }
    
    func styleButtonText(title: String) -> NSMutableAttributedString {
            
            let attributedString = NSMutableAttributedString(
                string: title,
                attributes: [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)
                ]
            )
            
            let prefix = "連絡信箱: \n"
            let prefixCount = prefix.count
            
            attributedString.addAttributes(
                [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24)],
                range: NSRange(location: 0, length: prefixCount)
            )

            attributedString.addAttributes(
                [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)],
                range: NSRange(location: prefixCount, length: email.count)
            )
            
            return attributedString
    }

    
    func styleButton(_ button: UIButton) {
        button.layer.cornerRadius = 10.0
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        button.shadow()
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
