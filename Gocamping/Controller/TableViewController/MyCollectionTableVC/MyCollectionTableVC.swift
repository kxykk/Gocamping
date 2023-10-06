//
//  MyCollectionTableVC.swift
//  Gocamping
//
//  Created by 康 on 2023/8/22.
//

import UIKit

class MyCollectionTableVC: UITableViewController {
 
    var userID = 0
    var isFromFirstVC = false
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ArticleManager.shared.myCollectedArticle.count
        
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureMyCollectedArticleCell(with: tableView, at: indexPath)
    }
    
    // MARK: - Button actions
    @IBAction func editBtnPressed(_ sender: Any) {
        
        let buttonPosition = (sender as AnyObject).convert(CGPoint.zero, to: self.tableView)
        guard let indexPath = self.tableView.indexPathForRow(at: buttonPosition) else {
            return
        }
        showEditAlert(at: indexPath)
    }
    // MARK: - Data for myCollectedArticleCell
    private func configureMyCollectedArticleCell(with tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "collectedArticleCell", for: indexPath) as! CollectedArticleCell
        let articles = ArticleManager.shared.myCollectedArticle
        let articleID = articles[indexPath.row].article_id
        cell.collectedArticleTitleLabel.text = articles[indexPath.row].article_title
        getUserInfo(articleID: articleID)
        getArticleImage(articleID: articleID, for: cell)
        cell.configureButton(isHidden: isFromFirstVC)
        return cell
    }
    
    private func getUserInfo(articleID: Int) {
        UserNetworkManager.shared.getUserByArticleID(articleID: articleID) { result, statusCode, error in
            guard let userID = result?.user?.user_id else {
                ShowMessageManager.shared.showToastGlobal(message: "取得使用者失敗！")
                return
            }
            self.userID = userID
        }
    }
    
    private func getArticleImage(articleID: Int, for cell: CollectedArticleCell) {
        ImageNetworkManager.shared.getImage(articleID: articleID, imageType: "title") { result, statusCode, error in
            guard let result = result, let imageURL = result.image?.imageURL else {
                cell.collectedArticleImage.image = UIImage(named: "風景照")
                return
            }
            self.downloadArticleImage(imageURL: imageURL, fro: cell)
        }
    }
    
    private func downloadArticleImage(imageURL: String, fro cell: CollectedArticleCell) {
        
        ImageNetworkManager.shared.downloadOrLoadImage(imageURL: imageURL) { data, error in
            if let data = data {
                cell.collectedArticleImage.image = UIImage(data: data)
            } else {
                cell.collectedArticleImage.image = UIImage(named: "風景照")
            }
        }
    }
    
    // MARK: - Edit alert
    private func showEditAlert(at indexPath: IndexPath) {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelCollectedAction = UIAlertAction(title: "取消收藏", style: .default) {_ in
            self.deleteCollectedArticle(at: indexPath)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        actionSheet.addAction(cancelCollectedAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    private func deleteCollectedArticle(at indexPath: IndexPath) {
        
        let articleID = ArticleManager.shared.myCollectedArticle[indexPath.row].article_id
        let userID = UserDefaults.standard.integer(forKey: userIDKey)
        ArticleNetworkManager.shared.deleteCollectedArticle(articleID: articleID, userID: userID) { result, statusCode, error in
            if let error = error {
                ShowMessageManager.shared.showToastGlobal(message: "取消收藏失敗！")
                return
            }
            DispatchQueue.main.async {
                ArticleManager.shared.myCollectedArticle.remove(at: indexPath.row)
                ShowMessageManager.shared.showToastGlobal(message: "取消收藏成功！")
                self.tableView.reloadData()
            }
            
        }
        
    }
  
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showcollectedArticle",
            let showArticleTableVC = segue.destination as? ShowArticleTableVC,
            let indexPath = self.tableView.indexPathForSelectedRow {
            showArticleTableVC.articleID = ArticleManager.shared.myCollectedArticle[indexPath.row].article_id
            showArticleTableVC.userID = self.userID
        }
    }
    

}
