//
//  RegisterVC.swift
//  Gocamping
//
//  Created by 康 on 2023/8/8.
//

import UIKit

protocol RegisterVCDelegate: AnyObject {
    func registerSuccess()
}

class RegisterVC: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var comfirmPwTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var showBtnPressed: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    var eyeIconImageView: UIImageView!


    
    weak var delegate: RegisterVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Privacy policy
        let privacyPolicyText = """
        \nGocamping Privacy Policy

        1.Introduction
        Thank you for choosing Gocamping (hereinafter referred to as "our app" or "the app"). \n
        We value your privacy and have created this Privacy Policy to explain how we collect, use, store, and protect your personal information.

        2.Data Collection
        Account Information
        When you register within the app, we collect your username and password. This information is used for creating articles and comments.

        3.Location Data
        We use your location data to provide navigation services.

        4.Data Usage
        Articles and Comments
        The articles and comments you create will be stored and made public for other users to view.

        5.Data Storage and Security
        All data is stored on our own server, which is located on our own computer. We only encrypt your password using bcrypt.hashpw.

        6.User Rights
        You have the right to access, correct, or delete your data within the app. If you wish to exercise these rights, you can do so directly within the app.

        7.Policy Changes
        If we make changes to this Privacy Policy, we will notify you on the app's homepage.

        8.Contact Us
        If you have any questions about this Privacy Policy, please contact us through gocamping919@gmail.com
"""
        ShowMessageManager.shared.showAlert(on: self, title: "Privacy policy", message: privacyPolicyText)
        
        eyeIconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        if let eyeIconImage = UIImage(named: "eye_icon") {
            eyeIconImageView.image = eyeIconImage
        }

        // ShowBtnPressed
        var config = UIButton.Configuration.filled()
        config.image = UIImage(named: "eye_closed")
        config.imagePadding = 5
        config.imagePlacement = .leading
        config.baseBackgroundColor = UIColor.clear
        showBtnPressed.configuration = config
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func registeBtnPressed(_ sender: Any) {
        
        //確認是否都有值
        guard let email = emailTextField.text, !email.isEmpty,
              let password = pwTextField.text, !password.isEmpty,
              let confirmPassword = comfirmPwTextField.text, !confirmPassword.isEmpty,
              let name = nameTextField.text, !name.isEmpty else {
            ShowMessageManager.shared.showAlert(on: self, title: "Error", message: "必須填入所有欄位")
            return
        }
        
        if !isValidEmail(email) {
            ShowMessageManager.shared.showAlert(on: self, title: "Error", message: "信箱格式錯誤")
            return
        }
        // 確認密碼是否匹配
        if password != confirmPassword {
            ShowMessageManager.shared.showAlert(on: self, title: "Error", message: "密碼需一致")
            return
        }
        
        // Create Time
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: Date())
        
        // Post user
        NetworkManager.shared.postUser(email: email, password: password, name: name, createDate: dateString) { result, statusCode, error in
            if let error = error {
                assertionFailure("Post user fail: \(error)")
                return
            }
            if statusCode == 409 {
                ShowMessageManager.shared.showToast(on: self, message: "信箱已註冊過")
                return
            } else {
                self.delegate?.registerSuccess()
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    @IBAction func showBtnPressed(_ sender: UIButton) {
        var config = showBtnPressed.configuration?.updated(for: sender)
        
        if pwTextField.isSecureTextEntry {
            pwTextField.isSecureTextEntry = false
            comfirmPwTextField.isSecureTextEntry = false
            config?.image = UIImage(named: "eye_open")
        } else {
            pwTextField.isSecureTextEntry = true
            comfirmPwTextField.isSecureTextEntry = true
            config?.image = UIImage(named: "eye_closed")
        }
        
        showBtnPressed.configuration = config
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
