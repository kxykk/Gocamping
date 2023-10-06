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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        registerNotifications()
    }
    // MARK: - Initial setup
    private func initialSetup() {
        
        var config = UIButton.Configuration.filled()
        config.image = UIImage(named: "eye_closed")
        config.imagePadding = 5
        config.imagePlacement = .leading
        config.baseBackgroundColor = UIColor.clear
        showBtnPressed.configuration = config
        
    }
    // MARK: - Notification
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleEmailSentNotification), name: NSNotification.Name("EmailSent"), object: nil)
    }
    
    // MARK: - Button actions
    @objc func handleEmailSentNotification(_ notification: Notification) {
        ShowMessageManager.shared.showToastGlobal(message: "發送信件完成")
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
    
    @IBAction func forgetPWBtnPressed(_ sender: Any) {
        let stroyboard = UIStoryboard(name: "Main", bundle: nil)
        if let forgetPasswordVC = stroyboard.instantiateViewController(identifier: "ForgetpasswordVC") as? ForgetpasswordVC {
            self.navigationController?.pushViewController(forgetPasswordVC, animated: true)
        }
    }
    
    @IBAction func btnLoginPressed(_ sender: Any) {
        
        guard let email = emailTextField.text, email.isEmpty == false else {
            ShowMessageManager.shared.showToastGlobal(message: "請輸入帳號(信箱)")
            return
        }
        guard let password = passwordTextField.text, password.isEmpty == false else {
            ShowMessageManager.shared.showToastGlobal(message: "請輸入密碼")
            return
        }
        login(email: email, password: password)
        
    }
    
    private func login(email: String, password: String) {
        UserNetworkManager.shared.login(email: email, password: password) { result, statusCode, error in
            if statusCode == 404 {
                ShowMessageManager.shared.showToastGlobal(message: "帳號有誤！")
            } else if statusCode == 401 {
                ShowMessageManager.shared.showToastGlobal(message: "密碼有誤！")
            }
            if let user = result?.user {
                self.setUserInfo(user: user)
                self.navigationController?.popViewController(animated: true)
                NotificationCenter.default.post(name: NSNotification.Name("userDidLogin"), object: nil)
            }
        }
    }
    // MARK: - Setup login user info
    private func setUserInfo(user: User) {
        
        UserDefaults.standard.set(user.user_id, forKey: userIDKey)
        userID = UserDefaults.standard.integer(forKey: userIDKey)
        UserDefaults.standard.set(user.name, forKey: userNameKey)
        userName = UserDefaults.standard.string(forKey: userNameKey)
        if user.introduction != "" {
            UserDefaults.standard.set(user.introduction, forKey: introductionKey)
        }
        getUserImage(userID: userID) { imageURL in
            if let imageURL = imageURL {
                UserDefaults.standard.set(imageURL, forKey: imageURLKey)
                self.loginVCDelegate?.didUpdateImageURL(imageURL)
            }
        }
    }
    
    private func getUserImage(userID: Int, completion: @escaping (String?) -> Void) {
        
        ImageNetworkManager.shared.getImageURLByUserID(userID: userID) { result, statusCode, error in
            guard let result = result, let imageURL = result.image?.imageURL else{
                completion(nil)
                return
            }
            return completion(imageURL)
        }
    }
    
    
    // MARK: End editing
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let registerVC = segue.destination as? RegisterVC {
            registerVC.registerDelegate = self
        }
    }
}
// MARK: - Extension for delegate
extension LoginVC: RegisterVCDelegate {
    
    func registerSuccess() {
        ShowMessageManager.shared.showToastGlobal(message: "註冊成功，請登入")
    }
    
}
