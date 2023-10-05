//  FirstTableVC.swift
//  Gocamping
//
//  Created by 康 on 2023/8/4.
//

import UIKit

class FirstTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    var animatedIndexPaths = Set<IndexPath>()
    var isFirstLoad = true
    
    // MARK: - Initialize
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        self.dataSource = self
        self.delegate = self
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ArticleManager.shared.allArticle.isEmpty ? 0 : ArticleManager.shared.allArticle.count * 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  indexPath.row % 2 == 0 ? 200 : 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return indexPath.row % 2 == 0 ? configureArticleCell(at: indexPath, for: tableView) : configureUserCell(at: indexPath, for: tableView)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        performCellAnimation(for: cell, at: indexPath)
    }
    
}

// MARK: - Data for articleCell
extension FirstTableView {
    
    private func configureArticleCell(at indexPath: IndexPath, for tableView: UITableView) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! ArticleCell
        
        let index = indexPath.row / 2
        guard index < ArticleManager.shared.allArticle.count else {
            return UITableViewCell()
        }
        
        let articles = ArticleManager.shared.allArticle[index]
        cell.articleID = articles.article_id
        cell.articleLabel.text = articles.article_title
        downloadImage(for: cell, with: articles)
        
        return cell
    }
    
    private func downloadImage(for cell: ArticleCell, with article: Articles) {
        
        let title = "title"
        cell.articleID = article.article_id
        
        NetworkManager.shared.getImage(articleID: cell.articleID, imageType: title) { result, statusCode, error in
            guard let result = result, let imageURL = result.image?.imageURL else {
                cell.articleImage.image = UIImage(named: "風景照")
                return
            }
            self.setArticlemage(from: imageURL, to: cell)
        }
    }
    
    private func setArticlemage(from imageURL: String, to cell: ArticleCell) {
        
        NetworkManager.shared.downloadOrLoadImage(imageURL: imageURL) { data, error in
            if let data = data {
                cell.articleImage.image = UIImage(data: data)
                return
            } else {
                cell.articleImage.image = UIImage(named: "風景照")
            }
        }
    }
    
    // MARK: - Data for userCell
    private func configureUserCell(at indexPath: IndexPath, for tableView: UITableView) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
        let userIndex = indexPath.row / 2
        if userIndex < UserManager.shared.userByArticle.count {
            let user = UserManager.shared.userByArticle[userIndex]
            populateUserData(to: cell, with: user)
            return cell
        }
        return UITableViewCell()
    }

    private func populateUserData(to cell: UserCell, with user: User) {
        cell.userName.text = user.name
        let userID = user.user_id
        
        NetworkManager.shared.getImageURLByUserID(userID: userID) { result, statusCode, error in
            guard let result = result, let imageURL = result.image?.imageURL else {
                if let originalImage = UIImage(named: "userDefault"),
                   let image = UIImage.thumbnail(from: originalImage) {
                    cell.userImage.image = image
                }
                return
            }
            self.setUserImage(from: imageURL, to: cell)
        }
    }
    
    private func setUserImage(from imageURL: String, to cell: UserCell) {
        
        NetworkManager.shared.downloadOrLoadImage(imageURL: imageURL) { data, error in
            if let data = data,
                  let originalImage = UIImage(data: data),
                  let image = UIImage.thumbnail(from: originalImage) {
                cell.userImage.image = image
                return
            } else {
                if let originalImage = UIImage(named: "userDefault"),
                   let image = UIImage.thumbnail(from: originalImage) {
                    cell.userImage.image = image
                }
            }
        }
    }
    
    // MARK: - Animation for cell
    private func performCellAnimation(for cell: UITableViewCell, at indexPath: IndexPath) {
        
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
        },completion: nil)
        
    }
    

    
    
}

