//
//  MyArticleTableVC.swift
//  Gocamping
//
//  Created by 康 on 2023/8/22.
//

import UIKit

class MyArticleTableVC: UITableViewController {
        
    var isFromFirstVC = false
    
    // MARK: - Liftcycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ArticleManager.shared.myArticle.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureMyArticleCell(with: tableView, at: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Button actions
    @IBAction func editBtnPressed(_ sender: Any) {
        
        let buttonPosition = (sender as AnyObject).convert(CGPoint.zero, to: self.tableView)
        guard let indexPath = self.tableView.indexPathForRow(at: buttonPosition) else {
            return
        }
        showEditAlert(at: indexPath)
        
    }
    
    // MARK: - Data for myArticleCell
    private func configureMyArticleCell(with tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "myArticleCell", for: indexPath) as! MyArticleCell
        
        let myArticles = ArticleManager.shared.myArticle
        cell.myArticleTitle.text = myArticles[indexPath.row].article_title
        downloadMyArticleImage(for: cell, with: myArticles[indexPath.row])
        
        cell.configureButton(isHidden: isFromFirstVC)
        
        return cell
    }
    
    func downloadMyArticleImage(for cell: MyArticleCell, with article: Articles) {
        let articleID = article.article_id
        let imageType = "title"
        ImageNetworkManager.shared.getImage(articleID: articleID, imageType: imageType) { result, statusCode, error in
            guard let result = result, let imageURL = result.image?.imageURL else {
                cell.myArticleImage.image = UIImage(named: "風景照")
                return
            }
            ImageNetworkManager.shared.downloadOrLoadImage(imageURL: imageURL) { data, error in
                if let data = data {
                    cell.myArticleImage.image = UIImage(data: data)
                } else {
                    cell.myArticleImage.image = UIImage(named: "風景照")
                }
            }
        }
    }


    // MARK: - Edit article
    private func showEditAlert(at indexPath: IndexPath) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "編輯", style: .default) {_ in
            self.performSegue(withIdentifier: "editSegue", sender: indexPath)
        }
        let deleteAction = UIAlertAction(title: "刪除", style: .default) {_ in
            self.deleteArticle(at: indexPath)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        actionSheet.addAction(editAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    private func deleteArticle(at indexPath: IndexPath) {
        let articleID = ArticleManager.shared.myArticle[indexPath.row].article_id
        ArticleNetworkManager.shared.deleteArticle(articleID: articleID) { result, statusCode, error in
            if let error = error {
                ShowMessageManager.shared.showToastGlobal(message: "刪除文章失敗")
                return
            }
            DispatchQueue.main.async {
                ArticleManager.shared.myArticle.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMyArticleSegue",
           let showArticleTableVC = segue.destination as? ShowArticleTableVC,
           let indexPath = self.tableView.indexPathForSelectedRow {
            let userID = UserDefaults.standard.integer(forKey: userIDKey)
            showArticleTableVC.articleID = ArticleManager.shared.myArticle[indexPath.row].article_id
            showArticleTableVC.userID = userID
        }
        else if segue.identifier == "editSegue",
                  let editArticleVC = segue.destination as? EditArticleVC,
                  let indexPath = sender as? IndexPath {
            let articleID = ArticleManager.shared.myArticle[indexPath.row].article_id
            editArticleVC.isFromEdit = true
            editArticleVC.articleID = articleID
        }
    }
    
}
