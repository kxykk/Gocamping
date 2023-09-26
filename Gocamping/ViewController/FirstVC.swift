//
//  ViewController.swift
//  Gocamping
//
//  Created by 康 on 2023/7/24.
//

import UIKit

class FirstViewController: UIViewController {
    
    
    @IBOutlet weak var searchArticlesBar: UISearchBar!
    @IBOutlet weak var firstTableView: FirstTableView!
    
    var noResultsLabel: UILabel!
    var activityIndicator: UIActivityIndicatorView!
    
    var lastSearchKeyword: String?
    var lastSearchResults: [Articles]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(NSHomeDirectory())
        
        // Label
        noResultsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: firstTableView.bounds.width, height: 50))
        noResultsLabel.text = "搜尋不到文章"
        noResultsLabel.textAlignment = .center
        noResultsLabel.textColor = .gray
        noResultsLabel.isHidden = true
        firstTableView.addSubview(noResultsLabel)
        self.view.bringSubviewToFront(noResultsLabel)
        
        // Indicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        
        // Show alert message
        let title = "愛護自然"
        let message = "親愛的露營愛好者，讓我們一同珍惜大自然的美麗。在享受戶外的同時，請記得愛護環境，將垃圾帶走。只有這樣，才能讓這片淨土永續美麗，讓未來的露營體驗依然如此迷人。"
        ShowMessageManager.shared.showAlert(on: self, title: title, message: message)
        
        searchArticlesBar.delegate = self
        ServeoManager.shared.serveoGroup.notify(queue: .main) {
            if self.lastSearchResults == nil {
                self.getAllArticle()
            }
        }

        
        NotificationCenter.default.addObserver(self, selector: #selector(userDidLogout), name: Notification.Name("UserDidLogout"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userDidDelete), name: Notification.Name("UserDidDelete"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ServeoManager.shared.serveoGroup.notify(queue: .main) {
            if self.lastSearchResults == nil {
                self.getAllArticle()
            }
        }
    }
    
    func getAllArticle() {
        let group = DispatchGroup()
        activityIndicator.startAnimating()
        self.firstTableView.isHidden = true
        // Get all articles information.
        NetworkManager.shared.getAllArticleIDandTitle { result, statusCode, error in
            if let articles = result?.articles {
                ArticleManager.shared.allArticle = articles
                
                for article in articles {
                    
                    
                    group.enter()
                    // Get all users by article information.
                    NetworkManager.shared.getUserByArticleID(articleID: article.article_id) { result, statusCode, error in
                        if let users = result?.user {
                            UserManager.shared.userByArticle.append(users)
                        }
                        group.leave()
                    }
                }
            }
            // Comfirm all async execution done.
            group.notify(queue: .main) {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.firstTableView.reloadData()
                    self.firstTableView.isHidden = false
                }
            }
        }
    }
    
    @objc func userDidLogout() {
        ShowMessageManager.shared.showToast(on: self, message: "登出成功！")
    }
    
    @objc func userDidDelete() {
        ShowMessageManager.shared.showToast(on: self, message: "刪除帳號成功")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showArticleSegue",
           let showArticleTableVC = segue.destination as? ShowArticleTableVC,
           let indexPath = self.firstTableView.indexPathForSelectedRow {
            showArticleTableVC.articleID = ArticleManager.shared.allArticle[indexPath.row / 2].article_id
            showArticleTableVC.userID = UserManager.shared.userByArticle[indexPath.row / 2].user_id
        }
    }
    
}

extension FirstViewController: UISearchBarDelegate {
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        activityIndicator.startAnimating()
        firstTableView.isHidden = true
        
        let group = DispatchGroup()
        let minimumShowTime = DispatchTime.now() + 0.5
        
        NetworkManager.shared.searchArticles(keyword: searchText) { result, statusCode, error in
            if let error = error {
                assertionFailure("Search article error: \(error)")
                return
            }
            
            if let articles = result?.articles {
                ArticleManager.shared.allArticle = articles
                self.lastSearchKeyword = searchText
                self.lastSearchResults = articles
                UserManager.shared.userByArticle.removeAll()
                
                for article in articles {
                    group.enter()
                    NetworkManager.shared.getUserByArticleID(articleID: article.article_id) { result, statusCode, error in
                        if let users = result?.user {
                            self.firstTableView.animatedIndexPaths.removeAll()
                            UserManager.shared.userByArticle.append(users)
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    DispatchQueue.main.asyncAfter(deadline: minimumShowTime) {
                        self.activityIndicator.stopAnimating()
                        self.firstTableView.isHidden = false
                        self.noResultsLabel.isHidden = true
                        self.firstTableView.tableFooterView = nil
                        self.firstTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                        self.firstTableView.reloadData()
                    }
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: minimumShowTime) {
                    ArticleManager.shared.allArticle = []
                    self.lastSearchKeyword = nil
                    self.lastSearchResults = nil
                    UserManager.shared.userByArticle.removeAll()
                    self.activityIndicator.stopAnimating()
                    self.firstTableView.isHidden = false
                    self.noResultsLabel.isHidden = false 
                    self.firstTableView.tableFooterView = self.noResultsLabel
                    self.firstTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                    self.firstTableView.reloadData()
                }
            }
        }
    }  
}
