//
//  ShowArticleTableVC.swift
//  Gocamping
//
//  Created by 康 on 2023/8/22.
//

import UIKit

class ShowArticleTableVC: UITableViewController {
    
    @IBOutlet weak var collectedBtnPressed: UIBarButtonItem!

    var articleContents = [CombinedItem]()
    var comments = [Comment]()
    var shouldReloadRow: [Int: Bool] = [:]
    var userImage: UIImage?
    var currentCommentText: String?
    var articleID: Int = 0
    var userID: Int = 0
    var userName = ""
    let text = "text"
    let image = "image"

    var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getArticleContent()
    }
    
    // MARK: - Initial setup
    private func initialSetup() {
        setupTableView()
        setupActivityIndicator()
    }
    
    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
    }
    
    private func setupTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 75
        setupTableViewSeperator()
    }
    
    private func setupTableViewSeperator() {
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.gray
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - Get artilce content
    private func getArticleContent() {
        let dispatchGroup = DispatchGroup()
        
        activityIndicator.startAnimating()
        
        collectedBtnShow()
        
        fetchComments(with: dispatchGroup)
        fetchArticleInfo(with: dispatchGroup)
        fetchUserImage(with: dispatchGroup)
        
        dispatchGroup.notify(queue: .main) {
            self.activityIndicator.stopAnimating()
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Setup button
    private func collectedBtnShow() {
        UserNetworkManager.shared.getUserByArticleID(articleID: articleID) { result, statusCode, error in
            
            self.userID = UserDefaults.standard.integer(forKey: userIDKey)
            if let user = result?.user {
                self.userName = user.name
                if self.userID == user.user_id {
                    self.navigationItem.rightBarButtonItems = nil
                } else {
                    self.navigationItem.rightBarButtonItem = self.collectedBtnPressed
                }
            }
        }
    }

    // MARK: - Get article info
    private func fetchArticleInfo(with dispatchGroup: DispatchGroup) {
        dispatchGroup.enter()
        ArticleNetworkManager.shared.getDetailsByArticleID(articleID: articleID) { result, statusCode, error in
            if let articleContent = result?.combinedItems {
                self.articleContents = articleContent
            }
            dispatchGroup.leave()
        }
    }
    
    // MARK: - Get comments info
    private func fetchComments(with dispatchGroup: DispatchGroup) {
        dispatchGroup.enter()
        CommentNetworkManager.shared.getCommentByArticleID(articleID: articleID) { result, statusCode, error in
            if let comments = result?.comments {
                self.comments = comments
            }
            dispatchGroup.leave()
        }
    }
    
    // MARK: - Get user image
    private func fetchUserImage(with dispatchGroup: DispatchGroup) {
        dispatchGroup.enter()
        ImageNetworkManager.shared.getImageURLByUserID(userID: userID) { result, statusCode, error in
            guard let imageURL = result?.image?.imageURL else {
                self.userImage = UIImage(named: "userDefault")
                dispatchGroup.leave()
                return
            }
            self.downloadUserImage(imageURL: imageURL, with: dispatchGroup)
        }
    }
    
    private func downloadUserImage(imageURL: String, with dispatchGroup: DispatchGroup) {
        ImageNetworkManager.shared.downloadOrLoadImage(imageURL: imageURL) { data, error in
            if let data = data,
               let originalImage = UIImage(data: data),
               let image = UIImage.thumbnail(from: originalImage) {
                self.userImage = image
            } else {
                self.userImage = UIImage(named: "userDefault")
            }
            dispatchGroup.leave()
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows(for: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRow(at: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellForRow(at: indexPath)
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
    
    private func numberOfRows(for section: Int) -> Int {
        switch section {
        case 0: return 1 + 1 // 1 = Seperator
        case 1: return articleContents.count + 1 // 1 = Seperator
        case 2: return 1
        case 3: return comments.count
        default: return 0
        }
    }
    
    private func heightForRow(at indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return heightForUserRow(at: indexPath)
        case 1: return heightForArticleRow(at: indexPath)
        case 2: return 100
        case 3: return 120
        default: return 0
        }
    }
    // MARK: - Data for row
    private func heightForUserRow(at indexPath: IndexPath) -> CGFloat{
        // Seperator
        if indexPath.row == 1 {
            return 2
        }
        return 100
    }
    
    private func heightForArticleRow(at indexPath: IndexPath) -> CGFloat{
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
    }
    
    private func cellForRow(at indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0: return cellForUserSection(at: indexPath)
        case 1: return cellForArticleSection(at: indexPath)
        case 2: return cellForMyCommentSection(at: indexPath)
        case 3: return cellForCommentSection(at: indexPath)
        default: return UITableViewCell()
        }
    }
    
    // MARK: - Cell for user
    private func cellForUserSection(at indexPath: IndexPath) -> UITableViewCell {
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
    }
    
    // MARK: - Cell for article
    private func cellForArticleSection(at indexPath: IndexPath) -> UITableViewCell {
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
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "showImageCell", for: indexPath) as! ShowImageCell
            guard let imageURL = content.item.imageURL else {
                return cell
            }
            ImageNetworkManager.shared.downloadOrLoadImage(imageURL: imageURL) { data, error in
                if let data = data {
                    cell.showImageView.image = UIImage(data: data)
                } else {
                    cell.showImageView.image = UIImage(named: "風景照")
                }
            }
            return cell
        }
    }
    
    // MARK: - Cell for mycomment
    private func cellForMyCommentSection(at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "showMyCommentCell", for: indexPath) as! ShowMyCommentCell
        cell.delegate = self
        return cell
    }
    
    // MARK: - Cell for othercomment
    private func cellForCommentSection(at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "showCommentCell", for: indexPath) as! ShowCommentCell
        let comment = comments[indexPath.row]
        let userID = UserDefaults.standard.integer(forKey: userIDKey)
        let commentUserID = comment.user_id
        
        cell.commentTextView.text = comment.comment
        shouldReloadRow[indexPath.row] = true
        let dispatchGroup = DispatchGroup()
        
        setupButton(commentUserID: commentUserID, for: cell, at: indexPath)
        getUser(userID: commentUserID, fro: cell, at: indexPath, dispatchGroup: dispatchGroup)
        getUserImage(userID: commentUserID, for: cell, at: indexPath, dispatchGroup: dispatchGroup)

        dispatchGroup.notify(queue: .main) {
            if let shouldReload = self.shouldReloadRow[indexPath.row], shouldReload {
                let indexPathToReload = IndexPath(row: indexPath.row, section: indexPath.section)
                self.tableView.reloadRows(at: [indexPathToReload], with: .automatic)
            }
        }

        return cell
    }
    
    // MARK: - Data for commentCell
    private func setupButton(commentUserID: Int, for cell: ShowCommentCell, at indexPath: IndexPath) {
        if commentUserID == userID {
            cell.editCommentBtnPressed.isHidden = false
        } else {
            cell.editCommentBtnPressed.isHidden = true
        }
        cell.editCommentBtnPressed.tag = indexPath.row
        cell.editCommentBtnPressed.addTarget(self, action: #selector(editCommentBtnPressed(_:)), for: .touchUpInside)
    }
    
    private func getUser(userID: Int, fro cell: ShowCommentCell, at indexPath: IndexPath, dispatchGroup: DispatchGroup) {
        dispatchGroup.enter()
        UserNetworkManager.shared.getUser(userID: userID) { result, statusCode, error in
            if let user = result?.user {
                cell.usernameLabel.text = user.name
                self.shouldReloadRow[indexPath.row] = false
                dispatchGroup.leave()
            }
        }
    }
    
    private func getUserImage(userID: Int, for cell: ShowCommentCell, at indexPath: IndexPath, dispatchGroup: DispatchGroup) {
        dispatchGroup.enter()
        ImageNetworkManager.shared.getImageURLByUserID(userID: userID) { result, statusCode, error in
            guard let imageURL = result?.image?.imageURL else {
                cell.userImageView.image = UIImage(named: "userDefault")
                dispatchGroup.leave()
                return
            }
            self.downloadCommentUserImage(imageURL: imageURL, for: cell, dispatchGroup: dispatchGroup)
        }
    }
    
    private func downloadCommentUserImage(imageURL: String, for cell: ShowCommentCell, dispatchGroup: DispatchGroup) {
        ImageNetworkManager.shared.downloadOrLoadImage(imageURL: imageURL) { data, error in
            if let data = data,
               let originalImage = UIImage(data: data),
               let image = UIImage.thumbnail(from: originalImage) {
                cell.userImageView.image = image
                dispatchGroup.leave()
            } else {
                cell.userImageView.image = UIImage(named: "userDefault")
                dispatchGroup.leave()
            }
        }
    }

    // MARK: - Button actions
    @objc func editCommentBtnPressed(_ sender: UIButton) {
        let row = sender.tag
        let selectedComment = comments[row]
        let commentID = selectedComment.comment_id
        showCommentAlert(commentID: commentID, at: row)
    }
    
    @IBAction func collectedBtnPressed(_ sender: Any) {
        
        userID = UserDefaults.standard.integer(forKey: userIDKey)
        
        ArticleNetworkManager.shared.postarticleCollection(articleID: articleID, userID: userID) { result, statusCode, error in
            if self.userID == 0 {
                ShowMessageManager.shared.showToastGlobal(message: "您尚未登入！")
                return
            }
            if let error = error {
                assertionFailure("Collect error: \(error)")
                return
            }
            if statusCode == 409 {
                ShowMessageManager.shared.showToastGlobal(message: "已收藏")
            } else {
                ShowMessageManager.shared.showToastGlobal(message: "收藏成功！")
            }
        }
    }
    
    @IBAction func sendCommentBtnPressed(_ sender: Any) {
        
        userID = UserDefaults.standard.integer(forKey: userIDKey)
        if userID == 0 {
            let message = "您尚未登入"
            ShowMessageManager.shared.showToastGlobal(message: message)
            return
        }
        guard let comment = currentCommentText, comment.isEmpty == false else {
            let message = "您尚未輸入評論"
            ShowMessageManager.shared.showToastGlobal(message: message)
            return
        }
        postComment(articleID: articleID, userID: userID, comment: comment)
    }
    
    private func postComment(articleID: Int, userID: Int, comment: String) {
        
        CommentNetworkManager.shared.postComment(articleID: articleID, userID: userID, comment: comment) { result, statusCode, error in
            if let error = error {
                ShowMessageManager.shared.showToastGlobal(message: "發佈評論失敗！")
                return
            }
            
            self.currentCommentText = ""
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? ShowMyCommentCell {
                cell.showMyCommentTextView.text = ""

                self.getArticleContent()
                ShowMessageManager.shared.showToastGlobal(message: "評論上傳成功")
            }
        }
    }
    
    private func showCommentAlert(commentID: Int, at row: Int) {

        let alertSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "刪除", style: .default) {_ in
            self.deleteComment(commentID: commentID, at: row)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        alertSheet.addAction(deleteAction)
        alertSheet.addAction(cancelAction)
        
        self.present(alertSheet, animated: true, completion: nil)
    }
    
    private func deleteComment(commentID: Int, at row: Int) {
        CommentNetworkManager.shared.deleteComment(commentID: commentID) { result, statusCode, error in
            if let result = result {
                self.comments.remove(at: row)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    ShowMessageManager.shared.showToastGlobal(message: "刪除成功")
                }
            }
        }
    }
}

// MARK: - Extension for delegate
extension ShowArticleTableVC: ShowMyCommentCellDelegate {
    func didChangeCommentText(_ text: String) {
        currentCommentText = text
    }
}
