//
//  ViewController.swift
//  Gocamping
//
//  Created by 康 on 2023/7/24.
//

import UIKit
import Network


class FirstViewController: UIViewController {
    
    @IBOutlet weak var searchArticlesBar: UISearchBar!
    @IBOutlet weak var firstTableView: FirstTableView!
    var noResultsLabel: UILabel!
    var activityIndicator: UIActivityIndicatorView!
    let tableViewContainer = UIView()
    var lastSearchKeyword: String?
    var lastSearchResults: [Articles]?
    let monitor = NWPathMonitor()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        registerNotifications()
        monitorNetwork()
        self.view.backgroundColor = UIColor.lightGreen
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchInitialArticlesIfNeeded()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Initial Setup
    private func initialSetup() {
        setupSearchBar()
        setupTableViewContainer()
        setupTableView()
        setupNoResultsLabel()
        setupActivityIndicator()
    }
    
    private func setupTableViewContainer() {
        tableViewContainer.frame = CGRect(x: 0, y: searchArticlesBar.frame.maxY, width: self.view.bounds.width, height: self.view.bounds.height - searchArticlesBar.frame.maxY)
        tableViewContainer.backgroundColor = .clear
        tableViewContainer.shadow()
        self.view.addSubview(tableViewContainer)
    }
    
    private func setupTableView() {
        firstTableView.frame = tableViewContainer.bounds
        firstTableView.layer.cornerRadius = 10
        firstTableView.clipsToBounds = true
        tableViewContainer.addSubview(firstTableView)
    }
    
    private func setupSearchBar() {
        searchArticlesBar.backgroundImage = UIImage()
        searchArticlesBar.searchTextField.backgroundColor = .white
        searchArticlesBar.searchTextField.layer.borderWidth = 0.0
        searchArticlesBar.shadow()
        searchArticlesBar.delegate = self
    }
    
    private func setupNoResultsLabel() {
        noResultsLabel = firstTableView.addNoResultsLabel(withText: "搜尋不到文章")
    }
    
    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
    }
    
    private func fetchInitialArticlesIfNeeded() {
        if self.lastSearchResults == nil {
            self.getAllArticle()
        }
    }
    
    private func getAllArticle() {
            let group = DispatchGroup()
            activityIndicator.startAnimating()
            self.firstTableView.isHidden = true
            
            group.enter()
            fetchArticles(group: group)
            
            group.notify(queue: .main) {
                self.activityIndicator.stopAnimating()
                self.firstTableView.reloadData()
                self.firstTableView.isHidden = false
            }
        }
    
    private func fetchArticles(group: DispatchGroup) {
        NetworkManager.shared.getAllArticleIDandTitle { result, statusCode, error in
            if let articles = result?.articles {
                ArticleManager.shared.allArticle = articles
                for article in articles {
                    group.enter()
                    self.fetchUsersByArticleID(article: article, group: group)
                }
            }
            group.leave()
        }
    }
    
    private func fetchUsersByArticleID(article: Articles, group: DispatchGroup) {
        NetworkManager.shared.getUserByArticleID(articleID: article.article_id) { result, statusCode, error in
            if let users = result?.user {
                UserManager.shared.userByArticle.append(users)
            }
            group.leave()
        }
    }
    
    
    private func monitorNetwork() {
        monitor.pathUpdateHandler = { path in
            self.monitor.pathUpdateHandler = { path in
                if path.status == .satisfied {
                    print("We're connected!")
                } else {
                    DispatchQueue.main.async {
                        ShowMessageManager.shared.showAlert(on: self, title: "網路連接失敗", message: "請檢查您的網絡設置")
                    }
                }
            }
        }
    }
    
    // MARK: - Notifications
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(userDidLogout), name: Notification.Name("UserDidLogout"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userDidDelete), name: Notification.Name("UserDidDelete"), object: nil)
    }
    
    @objc func userDidLogout() {
        ShowMessageManager.shared.showToastGlobal(message: "登出成功！")
    }
    
    @objc func userDidDelete() {
        ShowMessageManager.shared.showToastGlobal(message: "刪除帳號成功")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showArticleSegue",
           let showArticleTableVC = segue.destination as? ShowArticleTableVC,
           let indexPath = self.firstTableView.indexPathForSelectedRow {
            showArticleTableVC.articleID = ArticleManager.shared.allArticle[indexPath.row / 2].article_id
            showArticleTableVC.userID = UserManager.shared.userByArticle[indexPath.row / 2].user_id
        } else if segue.identifier == "showUserSegue",
                  let thirdVC = segue.destination as? ThirdViewController,
                  let indexPath = self.firstTableView.indexPathForSelectedRow {
            thirdVC.userID = UserManager.shared.userByArticle[indexPath.row / 2].user_id
            thirdVC.isFromFirstVC = true
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
