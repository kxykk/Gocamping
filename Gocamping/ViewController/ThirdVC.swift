//
//  ThirdViewController.swift
//  Gocamping
//
//  Created by 康 on 2023/7/24.
//

import UIKit

class ThirdViewController: UIViewController {

    @IBOutlet weak var thirdTableViewSegment: UISegmentedControl!
    @IBOutlet weak var userIntroduction: UITextView!
    @IBOutlet weak var toFollow: UIButton!
    @IBOutlet weak var howManyArticle: UILabel!
    @IBOutlet weak var followerNumber: UILabel!
    @IBOutlet weak var followingNumber: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!

    @IBOutlet var containrViews: [UIView]!
    @IBOutlet weak var createArticleBtnPressed: UIButton!
    @IBOutlet weak var loginBtnPressed: UIButton!
    
    var myArticleTableVC: MyArticleTableVC?
    var myCollectionTableVC: MyCollectionTableVC?
    
    var isFromEdit = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tabBarController = self.tabBarController,
           let viewControllers = tabBarController.viewControllers {
            
            for viewController in viewControllers {
                if let fifthVC = viewController as? FifthViewController {
                    fifthVC.fifthVCDelegate = self
                    break
                }
            }
        }
        
        for child in children {
            if let childVC = child as? MyArticleTableVC {
                myArticleTableVC = childVC
            }
        }
        for child in children {
            if let childVC = child as? MyCollectionTableVC {
                myCollectionTableVC = childVC
            }
        }
        // Follow function 先不要
        followerNumber.isHidden = true
        followingNumber.isHidden = true
        toFollow.isHidden = true
        
        
        // CreateBtnPressed frame
        createArticleBtnPressed.setImage(UIImage(named: "plus"), for: .normal)
        createArticleBtnPressed.setTitle("", for: .normal)
        createArticleBtnPressed.setTitleColor(.black, for: .normal)
        createArticleBtnPressed.imageView?.contentMode = .scaleAspectFit
    }
    override func viewWillAppear(_ animated: Bool) {

        NotificationCenter.default.addObserver(self, selector: #selector(loginSuccess), name: NSNotification.Name("userDidLogin"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(postContentSuccess), name: NSNotification.Name("postContentSuccess"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(editContentSuccess), name: NSNotification.Name("editContentSuccess"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userProfileDidUpdate), name: NSNotification.Name("userProfileDidUpdate"), object: nil)
        if !isFromEdit {
            let introduction = UserDefaults.standard.string(forKey: introductionKey)
            userIntroduction.text = introduction
        }
        isFromEdit = false
        if let filename = UserDefaults.standard.string(forKey: imageURLKey),
           let originalImage = CacheManager.shared.load(filename: filename),
           let image = UIImage.thumbnail(from: originalImage) {
            userImage.image = image
        } else {
            if let originalImage = UIImage(named: "userDefault"),
                let image = UIImage.thumbnail(from: originalImage) {
                userImage?.image = image
            }
        }
        
        getCollectedArticle()
        getMyArticle()
        updateUIBaseOnLoginStates()
    }
    
    func getCollectedArticle() {
        let userID = UserDefaults.standard.integer(forKey: userIDKey)
        if userID != 0 {
            NetworkManager.shared.getCollectedArticle(userID: userID) { result, statusCode, error in
                if let error = error {
                    assertionFailure("Get collected articles error: \(error)")
                    return
                }
                if let articles = result?.articles {
                    DispatchQueue.main.async {
                        ArticleManager.shared.myCollectedArticle = articles
                        self.myCollectionTableVC?.tableView.reloadData()
                    }
                }
            }
        } else {
            ArticleManager.shared.myCollectedArticle = []
        }
    }
    
    func getMyArticle() {
        
        userName.text = UserDefaults.standard.string(forKey: userNameKey)

        let dispatchGroup = DispatchGroup()
        let userID = UserDefaults.standard.integer(forKey: userIDKey)
        if userID != 0 {
            dispatchGroup.enter()
            NetworkManager.shared.getMyArticle(userID: userID) { result, statusCode, error in
                if let error = error {
                    assertionFailure("Get my articles error: \(error)")
                    return
                }
                if let articles = result?.articles {
                    ArticleManager.shared.myArticle = articles
                    let articleCount = ArticleManager.shared.myArticle.count
                    let content = "有\(articleCount)篇文章"
                    self.howManyArticle.text = content
                }
                dispatchGroup.leave()
                dispatchGroup.notify(queue: .main, execute: {
                    self.myArticleTableVC?.tableView.reloadData()
                })
            }
        } else {
            ArticleManager.shared.allArticle = []
        }


    }
    
    func updateUIBaseOnLoginStates() {
        let userID = UserDefaults.standard.integer(forKey: userIDKey)
        if userID == 0 {
            loginBtnPressed.isHidden = false
            containrViews.forEach { $0.isHidden = true }
            createArticleBtnPressed.isHidden = true
        } else {
            loginBtnPressed.isHidden = true
            containrViews.forEach { $0.isHidden = false }
            createArticleBtnPressed.isHidden = false
            thirdTableViewSegment.selectedSegmentIndex = 0
            segmentChanged(thirdTableViewSegment)
            getMyArticle()
        }
    }
    
    func updateUserIntroduction() {
        if let introduction = UserDefaults.standard.string(forKey: introductionKey) {
            userIntroduction.text = introduction
        }
    }
    
    @objc func postContentSuccess() {
        ShowMessageManager.shared.showToast(on: self, message: "創建文章成功")
    }
    @objc func editContentSuccess() {
        ShowMessageManager.shared.showToast(on: self, message: "編輯文章成功")
    }
    @objc func userProfileDidUpdate() {
        ShowMessageManager.shared.showToast(on: self, message: "編輯成功")
    }
    
    @IBAction func createArticleBtnPressed(_ sender: Any) {
        
    }
    
    @IBAction func editBtnPressed(_ sender: UIButton) {
        let userID = UserDefaults.standard.integer(forKey: userIDKey)
        if userID == 0 {
            ShowMessageManager.shared.showToast(on: self, message: "您尚未登入！")
            return
        } else {
            performSegue(withIdentifier: "editProfileSegue", sender: self)
        }
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        let userID = UserDefaults.standard.integer(forKey: userIDKey)
        if userID == 0 {
            createArticleBtnPressed.isHidden = true
            return
        }
        for(index, view) in containrViews.enumerated() {
            view.isHidden = index != sender.selectedSegmentIndex
        }
        if sender.selectedSegmentIndex != 0 {
            createArticleBtnPressed.isHidden = true
        } else {
            createArticleBtnPressed.isHidden = false
        }
    }
    
    @objc func loginSuccess() {
        if let hasUserName = UserDefaults.standard.string(forKey: userNameKey) {
            ShowMessageManager.shared.showToast(on: self, message: "登入成功 \(hasUserName)")
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "myArticleSegue", let myArticleTableVC = segue.destination as? MyArticleTableVC {
            self.myArticleTableVC = myArticleTableVC
        } else if segue.identifier == "collectedArticleSegue", let myCollectionTableVC = segue.destination as? MyCollectionTableVC {
            self.myCollectionTableVC = myCollectionTableVC
        } else if segue.identifier == "editProfileSegue", let editProfileVC = segue.destination as? EditProfileVC {
            editProfileVC.delegate = self
        } else if segue.identifier == "loginSegue", let loginVC = segue.destination as? LoginVC {
            loginVC.loginVCDelegate = self
        }
    }
    

}
extension ThirdViewController: EditProfileDelegate {
    func didUpdateIntroduction(_ introduction: String) {
        userIntroduction.text = introduction
        isFromEdit = true
    }
}

extension ThirdViewController: FifthVCDelegate {
    func didDeleteUserSuccessfully() {
        howManyArticle.text = ""
    }
    
    func didLogoutSuccessfully() {
        print("didLogoutSuccessfully called")
        howManyArticle.text = ""
    }
}

extension ThirdViewController: LoginVCDelegate {
    func didUpdateImageURL(_ imageURL: String) {
        if let originalImage = CacheManager.shared.load(filename: imageURL),
           let image = UIImage.thumbnail(from: originalImage) {
            userImage.image = image
        } else {
            if let originalImage = UIImage(named: "userDefault"),
                let image = UIImage.thumbnail(from: originalImage) {
                userImage?.image = image
            }
        }
    }
}
