//
//  MyCollectionTableVC.swift
//  Gocamping
//
//  Created by 康 on 2023/8/22.
//

import UIKit

class MyCollectionTableVC: UITableViewController {
 
    var userID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func editBtnPressed(_ sender: Any) {
        
        let buttonPosition = (sender as AnyObject).convert(CGPoint.zero, to: self.tableView)
        
        guard let indexPath = self.tableView.indexPathForRow(at: buttonPosition) else {
            print("沒有選定的行")
            return
        }
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelCollectedAction = UIAlertAction(title: "取消收藏", style: .default) {_ in

            let articleID = ArticleManager.shared.myCollectedArticle[indexPath.row].article_id
            let userID = UserDefaults.standard.integer(forKey: userIDKey)
            NetworkManager.shared.deleteCollectedAerticle(articleID: articleID, userID: userID) { result, statusCode, error in
                if let error = error {
                    assertionFailure("Delete collected article error: \(error)")
                    return
                }
                DispatchQueue.main.async {
                    ArticleManager.shared.myCollectedArticle.remove(at: indexPath.row)
                    ShowMessageManager.shared.showContainerViewToast(on: self, message: "取消收藏成功！")
                    self.tableView.reloadData()
                }
                
            }
            
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        actionSheet.addAction(cancelCollectedAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ArticleManager.shared.myCollectedArticle.count
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "collectedArticleCell", for: indexPath) as! CollectedArticleCell
        print("article = \(ArticleManager.shared.myCollectedArticle)")
        let articles = ArticleManager.shared.myCollectedArticle
        let articleID = articles[indexPath.row].article_id
        NetworkManager.shared.getUserByArticleID(articleID: articleID) { result, statusCode, error in
            if let error = error {
                assertionFailure("Get user error: \(error)")
                return
            }
            if let userID = result?.user?.user_id {
                self.userID = userID
            }
            
        }
        // Title
        cell.collectedArticleTitleLabel.text = articles[indexPath.row].article_title
        // Image
        NetworkManager.shared.getImage(articleID: articleID, imageType: "title") { result, statusCode, error in
            guard let result = result, let imageURL = result.image?.imageURL else {
                assertionFailure("Get image error: \(String(describing: error))")
                return
            }
            if let cacheImage = CacheManager.shared.load(filename: imageURL) {
                cell.collectedArticleImage.image = cacheImage
            }
            NetworkManager.shared.downloadImage(imageURL: imageURL) { data, error in
                guard let data = data else {
                    assertionFailure("Download image error: \(String(describing: error))")
                    return
                }
                try? CacheManager.shared.save(data: data, filename: imageURL)
                let image = UIImage(data: data)
                cell.collectedArticleImage.image = image
                DispatchQueue.main.async {
                    print("resutl: \(ArticleManager.shared.myCollectedArticle)")
                    print("result: \(ArticleManager.shared.myCollectedArticle.count)")
                }
            }
        }

        return cell
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
        if segue.identifier == "showcollectedArticle",
            let showArticleTableVC = segue.destination as? ShowArticleTableVC,
            let indexPath = self.tableView.indexPathForSelectedRow {
            showArticleTableVC.articleID = ArticleManager.shared.myCollectedArticle[indexPath.row].article_id
            showArticleTableVC.userID = self.userID
            print("***** \(ArticleManager.shared.myCollectedArticle[indexPath.row].article_id)")
            print("***** \(showArticleTableVC.articleID)")
        }
    }
    

}
