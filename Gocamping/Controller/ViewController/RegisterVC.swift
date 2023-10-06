//
//  RegisterVC.swift
//  Gocamping
//
//  Created by 康 on 2023/8/8.
//

import UIKit
import SafariServices

class RegisterVC: UIViewController, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var comfirmPwTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var showBtnPressed: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    var eyeIconImageView: UIImageView!
    
    weak var registerDelegate: RegisterVCDelegate?

    let privacyURLString = "https://www.privacypolicies.com/live/75ffc95b-f6c4-449b-a3a0-a36496662f94"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    // MARK: - Initial setup
    private func initialSetup() {

        eyeIconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        if let eyeIconImage = UIImage(named: "eye_icon") {
            eyeIconImageView.image = eyeIconImage
        }

        var config = UIButton.Configuration.filled()
        config.image = UIImage(named: "eye_closed")
        config.imagePadding = 5
        config.imagePlacement = .leading
        config.baseBackgroundColor = UIColor.clear
        showBtnPressed.configuration = config
        
    }
    
    // MARK: - Initial Setup
    @IBAction func privacPolicyBtnPressed(_ sender: Any) {
        didTapPrivacy()
    }
    
    // MARK: - Button actions
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
    
    @IBAction func registeBtnPressed(_ sender: Any) {
        
        guard validateInputs() else {
            return
        }
        
        guard let email = emailTextField.text,
              let password = pwTextField.text,
              let name = nameTextField.text else {
            return
        }
        
        let dateString = getCurrentDateString()
        
        postUser(email: email, password: password, name: name, createDate: dateString)
        
    }

    // MARK: - Confirm iuputs
    private func validateInputs() -> Bool {
        
        guard let email = emailTextField.text, !email.isEmpty,
              let password = pwTextField.text, !password.isEmpty,
              let confirmPassword = comfirmPwTextField.text, !confirmPassword.isEmpty,
              let name = nameTextField.text, !name.isEmpty else {
            ShowMessageManager.shared.showAlert(on: self, title: "Error", message: "必須填入所有欄位")
            return false
        }
        
        if !isValidEmail(email) {
            ShowMessageManager.shared.showAlert(on: self, title: "Error", message: "信箱格式錯誤")
            return false
        }
        
        if password != confirmPassword {
            ShowMessageManager.shared.showAlert(on: self, title: "Error", message: "密碼需一致")
            return false
        }
        
        return true
    }
    
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // MARK: - Create date
    private func getCurrentDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }

    //MARK: - Post user
    private func postUser(email: String, password: String, name: String, createDate: String) {
        UserNetworkManager.shared.postUser(email: email, password: password, name: name, createDate: createDate) { result, statusCode, error in
            if let error = error {
                ShowMessageManager.shared.showToastGlobal(message: "創建帳號失敗！")
                return
            }
            if statusCode == 409 {
                ShowMessageManager.shared.showToastGlobal(message: "信箱已被註冊過！")
                return
            } else {
                self.registerDelegate?.registerSuccess()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    // MARK: - Privacy url
    private func didTapPrivacy() {
        if let url = URL(string: privacyURLString) {
            let safari = SFSafariViewController(url: url)
            safari.delegate = self
            present(safari, animated: true, completion: nil)
        }
    }

    

    
    //MARK: - End editing
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
// MARK: - Protocol
protocol RegisterVCDelegate: AnyObject {
    func registerSuccess()
}

