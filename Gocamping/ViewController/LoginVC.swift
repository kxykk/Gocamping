//
//  LoginVC.swift
//  Gocamping
//
//  Created by 康 on 2023/8/8.
//

import UIKit

protocol LoginVCDelegate: AnyObject {
    func didUpdateImageURL(_ imageURL: String)
}

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var showBtnPressed: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    
    weak var loginVCDelegate: LoginVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // ShowBtnPressed
        var config = UIButton.Configuration.filled()
        config.image = UIImage(named: "eye_closed")
        config.imagePadding = 5
        config.imagePlacement = .leading
        config.baseBackgroundColor = UIColor.clear
        showBtnPressed.configuration = config
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(handleEmailSentNotification), name: NSNotification.Name("EmailSent"), object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func showBtnPressed(_ sender: UIButton) {
        var config = showBtnPressed.configuration?.updated(for: sender)
        
        if passwordTextField.isSecureTextEntry {
            passwordTextField.isSecureTextEntry = false
            config?.image = UIImage(named: "eye_open")
        } else {
            passwordTextField.isSecureTextEntry = true
            config?.image = UIImage(named: "eye_closed")
        }
        
        showBtnPressed.configuration = config
    }
    @IBAction func btnLoginPressed(_ sender: Any) {
        
        if emailTextField.text == "" {
            ShowMessageManager.shared.showToast(on: self, message: "請輸入帳號(信箱)")
            return
        }
        if passwordTextField.text == "" {
            ShowMessageManager.shared.showToast(on: self, message: "請輸入密碼")
            return
        }
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        NetworkManager.shared.login(email: email, password: password) { result, statusCode, error in
            if statusCode == 404 {
                ShowMessageManager.shared.showToast(on: self, message: "帳號有誤！")
            } else if statusCode == 401 {
                ShowMessageManager.shared.showToast(on: self, message: "密碼有誤！")
            }
            if let user = result?.user {
                
                UserDefaults.standard.set(user.user_id, forKey: userIDKey)
                userID = UserDefaults.standard.integer(forKey: userIDKey)
                UserDefaults.standard.set(user.name, forKey: userNameKey)
                userName = UserDefaults.standard.string(forKey: userNameKey)
                if result?.user?.introduction != "" {
                    UserDefaults.standard.set(user.introduction, forKey: introductionKey)
                }
                self.navigationController?.popViewController(animated: true)
                NotificationCenter.default.post(name: NSNotification.Name("userDidLogin"), object: nil)
                NetworkManager.shared.getImageURLByUserID(userID: userID) { result, statusCode, error in
                    if let error = error {
                        assertionFailure("Get image error: \(error)")
                        return
                    }
                    guard let result = result, let imageURL = result.image?.imageURL else{
                        return
                    }
                    UserDefaults.standard.set(imageURL, forKey: imageURLKey)
                    self.loginVCDelegate?.didUpdateImageURL(imageURL)
                }
                
            }
            
        }
    }
    
    @objc func handleEmailSentNotification(_ notification: Notification) {
        ShowMessageManager.shared.showToast(on: self, message: "發送信件完成")
    }
    
    @IBAction func forgetPWBtnPressed(_ sender: Any) {
        let stroyboard = UIStoryboard(name: "Main", bundle: nil)
        if let forgetPasswordVC = stroyboard.instantiateViewController(identifier: "ForgetpasswordVC") as? ForgetpasswordVC {
            self.navigationController?.pushViewController(forgetPasswordVC, animated: true)
        }
    }
    
    @IBAction func registerBtnPressed(_ sender: Any) {
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let registerVC = segue.destination as? RegisterVC {
            registerVC.registerDelegate = self
        }
    }
    
    
}

extension LoginVC: RegisterVCDelegate {
    
    func registerSuccess() {
        ShowMessageManager.shared.showToast(on: self, message: "註冊成功，請登入")
    }
    
}
