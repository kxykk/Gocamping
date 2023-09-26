//
//  MyArticleTableVC.swift
//  Gocamping
//
//  Created by 康 on 2023/8/22.
//

import UIKit

class MyArticleTableVC: UITableViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func editBtnPressed(_ sender: Any) {
        
        // Get indexPath
        let buttonPosition = (sender as AnyObject).convert(CGPoint.zero, to: self.tableView)
        guard let indexPath = self.tableView.indexPathForRow(at: buttonPosition) else {
            print("沒有選定的行")
            return
        }
        if ArticleManager.shared.myArticle.isEmpty {
               print("沒有文章可以編輯")
               return
        }
        
        // Edit lists
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let editAction = UIAlertAction(title: "編輯", style: .default) {_ in
            self.performSegue(withIdentifier: "editSegue", sender: indexPath)
        }
        let deleteAction = UIAlertAction(title: "刪除", style: .default) {_ in
            // 要在整理
            let articleID = ArticleManager.shared.myArticle[indexPath.row].article_id
            NetworkManager.shared.deleteArticle(articleID: articleID) { result, statusCode, error in
                if let error = error {
                    assertionFailure("Delete article error: \(error)")
                    return
                }
                DispatchQueue.main.async {
                    ArticleManager.shared.myArticle.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        actionSheet.addAction(editAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ArticleManager.shared.myArticle.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myArticleCell", for: indexPath) as! MyArticleCell
        let myArticles = ArticleManager.shared.myArticle
        // Title
        cell.myArticleTitle.text = myArticles[indexPath.row].article_title
        // Image
        loadImage(for: cell, with: myArticles[indexPath.row])
        
        return cell
    }
    
    
    func loadImage(for cell: MyArticleCell, with article: Articles) {
        let articleID = article.article_id
        let imageType = "title"
        
        NetworkManager.shared.getImage(articleID: articleID, imageType: imageType) { result, statusCode, error in
            if let error = error {
                assertionFailure("Get image error: \(error)")
                return
            }
            guard let result = result, let imageURL = result.image?.imageURL else {
                assertionFailure("Get image error: \(String(describing: error))")
                return
            }
            if let cacheImage = CacheManager.shared.load(filename: imageURL) {
                DispatchQueue.main.async {
                    cell.myArticleImage.image = cacheImage
                }
                return
            }
            NetworkManager.shared.downloadImage(imageURL: imageURL) { data, error in
                if let error = error {
                    assertionFailure("Download image error: \(error)")
                    return
                }
                if let data = data {
                    try? CacheManager.shared.save(data: data, filename: imageURL)
                    DispatchQueue.main.async {
                        cell.myArticleImage.image = UIImage(data: data)
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMyArticleSegue",
           let showArticleTableVC = segue.destination as? ShowArticleTableVC,
           let indexPath = self.tableView.indexPathForSelectedRow {
            print("Row \(indexPath.row) selected")
            let userID = UserDefaults.standard.integer(forKey: userIDKey)
            showArticleTableVC.articleID = ArticleManager.shared.myArticle[indexPath.row].article_id
            showArticleTableVC.userID = userID
        } else if segue.identifier == "editSegue",
                  let editArticleVC = segue.destination as? EditArticleVC,
                  let indexPath = sender as? IndexPath {
            let articleID = ArticleManager.shared.myArticle[indexPath.row].article_id
            editArticleVC.isFromEdit = true
            editArticleVC.articleID = articleID
        }
    }
    
}
