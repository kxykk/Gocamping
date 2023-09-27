//
//  ShowArticleTableVC.swift
//  Gocamping
//
//  Created by 康 on 2023/8/22.
//

import UIKit

class ShowArticleTableVC: UITableViewController {
    
    var articleID: Int = 0
    var userID: Int = 0
    var userName = ""
    var userImage: UIImage?
    var articleContents = [CombinedItem]()
    let text = "text"
    let image = "image"
    var currentCommentText: String?
    var comments = [Comment]()
    var commentUsers = [User]()
    var commentUserImage = [UIImage?]()
    
    var activityIndicator: UIActivityIndicatorView!
    
    
    @IBOutlet weak var collectedBtnPressed: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  ActivityIndicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        
        //getArticleContent()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 75
        
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.gray
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        print("**** \(articleID) ****")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getArticleContent()
    }
    
    func getArticleContent() {
        
        let dispatchGroup = DispatchGroup()
        
        activityIndicator.startAnimating()
        collectedBtnShow()
        
        // Get article info
        dispatchGroup.enter()
        NetworkManager.shared.getDetailsByArticleID(articleID: articleID) { result, statusCode, error in
            if let error = error {
                assertionFailure("Get details error: \(error)")
                return
            }
            if let articleContent = result?.combinedItems {
                self.articleContents = articleContent
            }
            dispatchGroup.leave()
        }
        
        // Get comment info
        NetworkManager.shared.getCommentByArticleID(articleID: articleID) { result, statusCode, error in
            if let error = error {
                assertionFailure("Get comments error: \(error)")
                return
            }
            if let comments = result?.comments {
                self.comments = comments
                
                // 收集所有需要的用戶ID
                let userIDs = comments.map { $0.user_id }
                
                // 獲取這些用戶的信息和圖像
                self.getUsersAndImages(userIDs: userIDs) { users, images in
                    self.commentUsers = users
                    self.commentUserImage = images
                    
                }
            }
        }
        
        // User image
        dispatchGroup.enter()
        NetworkManager.shared.getImageURLByUserID(userID: userID) { result, statusCode, error in
            if let error = error {
                assertionFailure("Get image error: \(error)")
                return
            }
            guard let imageURL = result?.image?.imageURL else {
                dispatchGroup.leave()
                return
            }
            NetworkManager.shared.downloadImage(imageURL: imageURL) { data, error in
                if let error = error {
                    assertionFailure("Download image error: \(error)")
                    return
                }
                if let data = data,
                   let originalImage = UIImage(data: data),
                   let image = UIImage.thumbnail(from: originalImage) {
                    self.userImage = image
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.activityIndicator.stopAnimating()
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
    
    // 這個函數負責獲取用戶信息和圖像
    func getUsersAndImages(userIDs: [Int], completion: @escaping ([User], [UIImage?]) -> Void) {
        var users = [User]()
        var images = [UIImage?]()
        
        let dispatchGroup = DispatchGroup()
        
        for userID in userIDs {
            dispatchGroup.enter()
            
            // 獲取用戶信息
            NetworkManager.shared.getUser(userID: userID) { result, statusCode, error in
                if let user = result?.user {
                    users.append(user)
                    
                    // 獲取用戶圖像
                    NetworkManager.shared.getImageURLByUserID(userID: userID) { result, statusCode, error in
                        guard let imageURL = result?.image?.imageURL else {
                            images.append(nil)
                            dispatchGroup.leave()
                            return
                        }
                        NetworkManager.shared.downloadImage(imageURL: imageURL) { data, error in
                            if let data = data,
                               let originalImage = UIImage(data: data),
                               let image = UIImage.thumbnail(from: originalImage) {
                                images.append(image)
                            } else {
                                images.append(nil)
                            }
                            dispatchGroup.leave()
                        }
                    }
                } else {
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(users, images)
            let commentSection = 3
            let range = NSMakeRange(commentSection, 1)
            let sections = NSIndexSet(indexesIn: range)
            self.tableView.reloadSections(sections as IndexSet, with: .automatic)
        }
    }
    
    
    @IBAction func collectedBtnPressed(_ sender: Any) {
        
        userID = UserDefaults.standard.integer(forKey: userIDKey)
        
        NetworkManager.shared.postarticleCollection(articleID: articleID, userID: userID) { result, statusCode, error in
            if self.userID == 0 {
                ShowMessageManager.shared.collectedArticleToast(on: self, message: "您尚未登入！")
                return
            }
            if let error = error {
                assertionFailure("Collect error: \(error)")
                return
            }
            if statusCode == 409 {
                ShowMessageManager.shared.collectedArticleToast(on: self, message: "已收藏")
            } else {
                ShowMessageManager.shared.collectedArticleToast(on: self, message: "收藏成功！")
            }
        }
    }
    
    @IBAction func sendCommentBtnPressed(_ sender: Any) {
        
        userID = UserDefaults.standard.integer(forKey: userIDKey)
        
        if userID == 0 {
            let message = "您尚未登入"
            ShowMessageManager.shared.collectedArticleToast(on: self, message: message)
            return
        }
        guard let comment = currentCommentText, comment.isEmpty == false else {
            let message = "您尚未輸入評論"
            ShowMessageManager.shared.collectedArticleToast(on: self, message: message)
            return
        }
        
        NetworkManager.shared.postComment(articleID: articleID, userID: userID, comment: comment) { result, statusCode, error in
            if let error = error {
                assertionFailure("Post comment error: \(error)")
                return
            }
            
            
            self.currentCommentText = ""
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? ShowMyCommentCell {
                cell.showMyCommentTextView.text = ""
                
                
                // 在這裡重新獲取文章和評論的內容
                self.getArticleContent()
                DispatchQueue.main.async {
                    let message = "評論上傳成功"
                    ShowMessageManager.shared.showToast(on: self, message: message)
                }
            }
        }
    }
    
    
    
    
    func collectedBtnShow() {
        NetworkManager.shared.getUserByArticleID(articleID: articleID) { result, statusCode, error in
            
            self.userID = UserDefaults.standard.integer(forKey: userIDKey)
            
            if let error = error {
                assertionFailure("Get userID error: \(error)")
                return
            }
            if let user = result?.user {
                self.userName = user.name
                //                if self.userID == user.user_id {
                //                    self.collectedBtnPressed.isHidden = true
                //                } else {
                //                    self.collectedBtnPressed.isHidden = false
                //                }
                if self.userID == user.user_id {
                    self.navigationItem.rightBarButtonItems = nil
                } else {
                    self.navigationItem.rightBarButtonItem = self.collectedBtnPressed
                }
            }
        }
        
    }
    
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1 + 1 // 1 = Seperator
        case 1:
            return articleContents.count + 1 // 1 = Seperator
        case 2:
            return 1
        case 3:
            return comments.count
        default:
            return 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            
            // Seperator
            if indexPath.row == 1 {
                let cell = UITableViewCell()
                cell.backgroundColor = UIColor.gray
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "showUserCell", for: indexPath) as! ShowUserCell
            cell.userNameTextLabel.text = userName
            
            if let image = userImage {
                cell.userImageView.image = image
            } else if let originalImage = UIImage(named: "userDefault"),
                      let image = UIImage.thumbnail(from: originalImage){
                cell.userImageView.image = image
            }
            
            
            return cell
            
        case 1:
            
            // Seperator
            if indexPath.row == articleContents.count {
                let cell = UITableViewCell()
                cell.backgroundColor = UIColor.gray
                return cell
            }
            
            let content = articleContents[indexPath.row]
            if content.type == text {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "showTextCell", for: indexPath) as! ShowTextCell
                cell.showTextView.text = content.item.content
                return cell
                
            } else if content.type == image {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "showImageCell", for: indexPath) as! ShowImageCell
                guard let imageURL = content.item.imageURL else {
                    return cell
                }
                if let cacheImage = CacheManager.shared.load(filename: imageURL) {
                    DispatchQueue.main.async {
                        cell.showImageView.image = cacheImage
                    }
                    return cell
                }
                NetworkManager.shared.downloadImage(imageURL: imageURL) { data, error in
                    if let error = error {
                        assertionFailure("Download image error: \(error)")
                        return
                    }
                    if let data = data {
                        try? CacheManager.shared.save(data: data, filename: imageURL)
                        DispatchQueue.main.async {
                            cell.showImageView.image = UIImage(data: data)
                        }
                    }
                }
                return cell
            }
            return UITableViewCell()
        case 2:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "showMyCommentCell", for: indexPath) as! ShowMyCommentCell
            cell.delegate = self
            return cell
            
        case 3:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "showCommentCell", for: indexPath) as! ShowCommentCell
            let comment = comments[indexPath.row]
            cell.commentTextView.text = comment.comment
            
            if indexPath.row < commentUserImage.count {
                if let image = commentUserImage[indexPath.row] {
                    cell.userImageView.image = image
                    cell.usernameLabel.text = commentUsers[indexPath.row].name
                }
            } else if let image = UIImage.thumbnail(from: UIImage(named: "userDefault")!) {
                cell.userImageView.image = image
            }
            
            
            
            return cell
        default:
            return UITableViewCell()
            
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            // Seperator
            if indexPath.row == 1 {
                return 2
            }
            return 100
        case 1:
            // seperator
            if indexPath.row == articleContents.count {
                return 2
            }
            let content = articleContents[indexPath.row]
            if content.type == text {
                return UITableView.automaticDimension
            } else {
                return 200
            }
        case 2:
            return 100
        case 3:
            return 120
        default:
            return 0
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Comment buttomLine
        if indexPath.section == 3 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 10)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
        }
        // Animation
        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: 0, y: 50)
        
        UIView.animate(withDuration: 0.5) {
            cell.alpha = 1
            cell.transform = CGAffineTransform(translationX: 0, y: 0)
        }
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

extension ShowArticleTableVC: ShowMyCommentCellDelegate {
    
    func didChangeCommentText(_ text: String) {
        currentCommentText = text
    }
    
    
}