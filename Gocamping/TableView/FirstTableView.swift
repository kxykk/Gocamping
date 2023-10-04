//  FirstTableVC.swift
//  Gocamping
//
//  Created by 康 on 2023/8/4.
//

import UIKit

class FirstTableView: UITableView, UITableViewDelegate, UITableViewDataSource {

    var animatedIndexPaths = Set<IndexPath>()
    var isFirstLoad = true
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.dataSource = self
        self.delegate = self
        
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.dataSource = self
        self.delegate = self
    }
        
    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if ArticleManager.shared.allArticle.isEmpty {
                return 0
            }
        // 因為有articlecell跟usercell 所以需要*2
        return ArticleManager.shared.allArticle.count * 2
    }
     

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row % 2 == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! ArticleCell
            // 因為上面*2的關係，所以allarticle陣列為indexPath的一半
            let index = indexPath.row / 2
            guard index < ArticleManager.shared.allArticle.count else {
                return UITableViewCell()
            }
            let articles = ArticleManager.shared.allArticle[index]
            
            cell.articleID = articles.article_id
            
            // Title
            cell.articleLabel.text = articles.article_title
            
            // Image
            downloadImage(for: cell, with: articles)
                    
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
            // Get user info
            getUserInfo(fro: cell, at: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row % 2 == 0{
            return 200
        } else {
            return 75
        }
    }


        
    func downloadImage(for cell: ArticleCell, with article: Articles) {
        let title = "title"
        cell.articleID = article.article_id

        NetworkManager.shared.getImage(articleID: cell.articleID, imageType: title) { result, statusCode, error in
            if let error = error {
                assertionFailure("Fail to get image: \(error)")
            }
            
            guard let result = result, let imageURL = result.image?.imageURL else {
                assertionFailure("Get image Fail: \(String(describing: result))")
                return
            }
            
            if let cacheImage = CacheManager.shared.load(filename: imageURL) {
                DispatchQueue.main.async {
                    cell.articleImage.image = cacheImage
                }
                return
            }
            
            NetworkManager.shared.downloadImage(imageURL: imageURL) { data, error in
                if let data = data {
                    try? CacheManager.shared.save(data: data, filename: imageURL)
                    DispatchQueue.main.async {
                        cell.articleImage.image = UIImage(data: data)
                    }
                }
            }
        }
    }

    
    func getUserInfo(fro cell: UserCell, at indexPath: IndexPath) {
        let userIndex = indexPath.row / 2
        if userIndex < UserManager.shared.userByArticle.count {
            let user = UserManager.shared.userByArticle[userIndex]
            cell.userName.text = user.name
            let userID = user.user_id
            NetworkManager.shared.getImageURLByUserID(userID: userID) { result, statusCode, error in
                if let error = error {
                    assertionFailure("Get image error: \(error)")
                    return
                }
                print("userID: \(userID)")
                guard let result = result, let imageURL = result.image?.imageURL else {
                    if let originalImage = UIImage(named: "userDefault"),
                       let image = UIImage.thumbnail(from: originalImage) {
                        cell.userImage.image = image
                    }
                    return
                }
                
                if let originalImage = CacheManager.shared.load(filename: imageURL),
                   let image = UIImage.thumbnail(from: originalImage) {
                    cell.userImage.image = image
                    return
                }
                NetworkManager.shared.downloadImage(imageURL: imageURL) { data, error in
                    if let data = data {
                        try? CacheManager.shared.save(data: data, filename: imageURL)
                        guard let originalImage = UIImage(data: data),
                              let image = UIImage.thumbnail(from: originalImage) else {
                                  return
                              }
                        DispatchQueue.main.async {
                            cell.userImage.image = image
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if !isFirstLoad || animatedIndexPaths.contains(indexPath) {
            return
        }
        
        animatedIndexPaths.insert(indexPath)
        
        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: cell.frame.size.width, y: 0)
        
        let animationDuration: TimeInterval = 0.5
        let delay: TimeInterval = 0.05 * Double(indexPath.row)
        
        UIView.animate(withDuration: animationDuration,
                       delay: delay,
                       options: [.curveEaseOut],
                       animations: {
                                cell.alpha = 1
                                cell.transform = CGAffineTransform.identity
                        },
                       completion: nil)
    }
    
}

