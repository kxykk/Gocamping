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
    
    @IBOutlet weak var myEmail: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var deleteAccountBtnPressed: UIButton!
    @IBOutlet weak var sharedBtnPressed: UIButton!
    @IBOutlet weak var reportBtnPressed: UIButton!
    @IBOutlet weak var logoutBtnPressed: UIButton!
    
    weak var fifthVCDelegate: FifthVCDelegate?
    
    let email = "gocamping919@gmail.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()


        // Do any additional setup after loading the view.
        
        
        reportBtnPressed.setImage(UIImage(named: "problems"), for: .normal)
        reportBtnPressed.setTitle("回報問題", for: .normal)
        reportBtnPressed.setTitleColor(.blue, for: .normal)
        reportBtnPressed.imageView?.contentMode = .scaleAspectFit
        
        sharedBtnPressed.setImage(UIImage(named: "share"), for: .normal)
        sharedBtnPressed.setTitle("分享App", for: .normal)
        sharedBtnPressed.setTitleColor(.blue, for: .normal)
        sharedBtnPressed.imageView?.contentMode = .scaleAspectFit
        sharedBtnPressed.isHidden = true
        
        deleteAccountBtnPressed.setImage(UIImage(named: "delete"), for: .normal)
        deleteAccountBtnPressed.setTitle("刪除帳號", for: .normal)
        deleteAccountBtnPressed.setTitleColor(.blue, for: .normal)
        deleteAccountBtnPressed.imageView?.contentMode = .scaleAspectFit
        
        logoutBtnPressed.setImage(UIImage(named: "logout"), for: .normal)
        logoutBtnPressed.setTitle("登出", for: .normal)
        logoutBtnPressed.setTitleColor(.blue, for: .normal)
        logoutBtnPressed.imageView?.contentMode = .scaleAspectFit
        
        iconImage?.image = UIImage(named: "icon")
        
        myEmail.text = "連絡信箱為: \n\(email)"
        
        
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
