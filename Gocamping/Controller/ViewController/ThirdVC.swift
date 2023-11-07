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
    @IBOutlet weak var editBtnPressed: UIButton!
    
    
    var myArticleTableVC: MyArticleTableVC?
    var myCollectionTableVC: MyCollectionTableVC?
    
    var isFromEdit = false
    var isFromFirstVC = false
    var userID = 0
    var otherUserIntroduction = ""
    var otherUserName = ""
    var otherUserImage: UIImage?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateState()
    }
    
    // MARK: - Initial Setup
    private func initialSetup() {
        setupUI()
        setupChildViewControllers()
        setupDelegate()
        fetchUserDataIfNeeded()
        registerNotifications()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        
        self.view.backgroundColor = UIColor.lightFlamingoPink
        
        userIntroduction.layer.cornerRadius = 10
        userIntroduction.shadow()
        
        thirdTableViewSegment.shadow()
        
        userImage.shadow()
        
        self.myArticleTableVC?.tableView.layer.cornerRadius = 10
        self.myArticleTableVC?.tableView.addShadow()
        
        self.myCollectionTableVC?.tableView.layer.cornerRadius = 10
        self.myCollectionTableVC?.tableView.addShadow()
        
        // Follow function 先不要
        followerNumber.isHidden = true
        followingNumber.isHidden = true
        toFollow.isHidden = true
        
        createArticleBtnPressed.setImage(UIImage(named: "plus"), for: .normal)
        createArticleBtnPressed.setTitle("", for: .normal)
        createArticleBtnPressed.setTitleColor(.black, for: .normal)
        createArticleBtnPressed.imageView?.contentMode = .scaleAspectFit
    }
    
    // MARK: - Setup childViewController
    private func setupChildViewControllers() {
        for child in children {
            if let childVC = child as? MyArticleTableVC {
                myArticleTableVC = childVC
            }
            if let childVC = child as? MyCollectionTableVC {
                myCollectionTableVC = childVC
            }
        }
    }
    // MARK: - Setup delegate
    private func setupDelegate() {
        if let tabBarController = self.tabBarController,
           let viewControllers = tabBarController.viewControllers {
            
            for viewController in viewControllers {
                if let fifthVC = viewController as? FifthViewController {
                    fifthVC.fifthVCDelegate = self
                    break
                }
            }
        }
    }
    
    // MARK: - Fetch user data
    private func fetchUserDataIfNeeded() {
        if isFromFirstVC {
            let group = DispatchGroup()
            getUserInfo(group: group)
            getUserImage(group: group)
            group.notify(queue: .main) {
                self.updateUIForFirstVC()
            }
        }
    }
    
    private func getUserInfo(group: DispatchGroup) {
        group.enter()
        UserNetworkManager.shared.getUser(userID: userID) { result, statusCode, error in
            if let user = result?.user {
                self.otherUserIntroduction = user.introduction ?? "無簡介"
                self.otherUserName = user.name
            }
            group.leave()
        }
    }
    
    private func getUserImage(group: DispatchGroup) {
        group.enter()
        ImageNetworkManager.shared.getImageURLByUserID(userID: userID) { result, statusCode, error in
            guard let result = result, let imageURL = result.image?.imageURL else {
                self.otherUserImage = UIImage(named: "userDefault")
                return
            }
            ImageNetworkManager.shared.downloadOrLoadImage(imageURL: imageURL) { data, error in
                if let data = data {
                    self.otherUserImage = UIImage(data: data)
                }
                group.leave()
            }
        }
    }
    
    // MARK: - Notification
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(loginSuccess), name: NSNotification.Name("userDidLogin"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(postContentSuccess), name: NSNotification.Name("postContentSuccess"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(editContentSuccess), name: NSNotification.Name("editContentSuccess"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userProfileDidUpdate), name: NSNotification.Name("userProfileDidUpdate"), object: nil)
    }
    
    // MARK: - Update User State
    private func updateState() {
        setupUser()
        updateUI()
        getCollectedArticle()
        getMyArticle()
        updateUIBaseOnLoginStates()
    }
    
    private func setupUser() {
        if !isFromFirstVC {
            userID = UserDefaults.standard.integer(forKey: userIDKey)
            userName.text = UserDefaults.standard.string(forKey: userNameKey)
        }
    }
    
    private func updateUI() {
        if isFromFirstVC {
            updateUIForFirstVC()
        } else {
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
        }
    }
    
    // MARK: - Get article lists
    func getCollectedArticle() {
        if userID != 0 {
            ArticleNetworkManager.shared.getCollectedArticle(userID: userID) { result, statusCode, error in
                if let articles = result?.articles {
                    disableTrace()
                    ArticleManager.shared.myCollectedArticle = articles
                    DispatchQueue.main.async {
                        self.myCollectionTableVC?.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    private func getMyArticle() {
        if userID != 0 {
            ArticleNetworkManager.shared.getMyArticle(userID: userID) { result, statusCode, error in
                if let articles = result?.articles {
                    disableTrace()
                    ArticleManager.shared.myArticle = articles
                    
                    let articleCount = ArticleManager.shared.myArticle.count
                    let content = "有\(articleCount)篇文章"
                    self.howManyArticle.text = content
                    DispatchQueue.main.async {
                        self.myArticleTableVC?.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    private func updateUIBaseOnLoginStates() {
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
    
    private func updateUIForFirstVC() {
        userIntroduction.text = otherUserIntroduction
        createArticleBtnPressed.isHidden = true
        editBtnPressed.isHidden = true
        disableTrace()
        
        if let unwrappedImage = otherUserImage {
            let image = UIImage.thumbnail(from: unwrappedImage)
            userImage?.image = image
        }
        thirdTableViewSegment.setTitle("\(otherUserName)的文章", forSegmentAt: 0)
        thirdTableViewSegment.setTitle("\(otherUserName)的收藏", forSegmentAt: 1)
        userName.text = otherUserName
    }
    
    // MARK: - Button & Segment actions
    @objc func postContentSuccess() {
        ShowMessageManager.shared.showToastGlobal(message: "創建文章成功")
    }
    @objc func editContentSuccess() {
        ShowMessageManager.shared.showToastGlobal(message: "編輯文章成功")
    }
    @objc func userProfileDidUpdate() {
        ShowMessageManager.shared.showToastGlobal(message: "編輯成功")
    }
    
    @objc func loginSuccess() {
        if let hasUserName = UserDefaults.standard.string(forKey: userNameKey) {
            ShowMessageManager.shared.showToastGlobal(message: "登入成功 \(hasUserName)")
        }
    }
    
    @IBAction func editBtnPressed(_ sender: UIButton) {
        if userID == 0 {
            ShowMessageManager.shared.showToastGlobal(message: "您尚未登入！")
            return
        } else {
            performSegue(withIdentifier: "editProfileSegue", sender: self)
        }
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
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
        
        if isFromFirstVC {
            createArticleBtnPressed.isHidden = true
        } else {
            createArticleBtnPressed.isHidden = sender.selectedSegmentIndex != 0
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if  segue.identifier == "myArticleSegue", let myArticleTableVC = segue.destination as? MyArticleTableVC {
            self.myArticleTableVC = myArticleTableVC
            if isFromFirstVC {
                myArticleTableVC.isFromFirstVC = true
            }
        }
        
        else if segue.identifier == "collectedArticleSegue", let myCollectionTableVC = segue.destination as? MyCollectionTableVC {
            if isFromFirstVC {
                myCollectionTableVC.isFromFirstVC = true
            }
            self.myCollectionTableVC = myCollectionTableVC
        }
        
        else if segue.identifier == "editProfileSegue", let editProfileVC = segue.destination as? EditProfileVC {
            editProfileVC.delegate = self
        }
        
        else if segue.identifier == "loginSegue", let loginVC = segue.destination as? LoginVC {
            loginVC.loginVCDelegate = self
        }
        
    }
    
    
}

// MARK: - Extension for delegates
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

