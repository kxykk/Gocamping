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
    let tableViewContainer = UIView()
    var lastSearchKeyword: String?
    var lastSearchResults: [Articles]?
    
    
    let monitor = NWPathMonitor()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        monitorNetwork()
        registerNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mbProgressHUD(text: "載入中...")
        self.firstTableView.isHidden = true
        self.getAllArticle()
    }

    // MARK: - Initial Setup
    private func initialSetup() {
        setupSearchBar()
        setupTableViewContainer()
        setupTableView()
        setupNoResultsLabel()
        setupViewControllerBackground()
    }
    
    private func setupViewControllerBackground() {
        self.view.backgroundColor = UIColor.lightGreen
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
        noResultsLabel = firstTableView.addNoResultsLabel(withText: "無搜尋結果")
    }

    
    // MARK: - Button actions
    @objc func userDidLogout() {
        ShowMessageManager.shared.showToastGlobal(message: "登出成功！")
    }
    
    @objc func userDidDelete() {
        ShowMessageManager.shared.showToastGlobal(message: "刪除帳號成功")
    }
    
    // MARK: - Get all article infos
    private func fetchInitialArticlesIfNeeded() {
        if self.lastSearchResults == nil {
            self.getAllArticle()
        }
    }
    
    private func getAllArticle() {
        let group = DispatchGroup()
        group.enter()
        fetchArticles(group: group)
        
        group.notify(queue: .main) {
            self.hideProgressedHUD()
            self.firstTableView.reloadData()
            self.firstTableView.isHidden = false
        }
    }
    
    private func fetchArticles(group: DispatchGroup) {
        ArticleNetworkManager.shared.getAllArticleIDandTitle { result, statusCode, error in
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
    
    // MARK: - Get user infos
    private func fetchUsersByArticleID(article: Articles, group: DispatchGroup) {
        UserNetworkManager.shared.getUserByArticleID(articleID: article.article_id) { result, statusCode, error in
            if let user = result?.user {
                UserManager.shared.userObjectByArticleID[article.article_id] = user
                UserManager.shared.userIDByArticleID[article.article_id] = user.user_id
            }
            group.leave()
        }
    }
    
    // MARK: - Check network
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
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = self.firstTableView.indexPathForSelectedRow {
            let articleIndex = indexPath.row / 2
            let articleID = ArticleManager.shared.allArticle[articleIndex].article_id
            
            if segue.identifier == "showArticleSegue",
               let showArticleTableVC = segue.destination as? ShowArticleTableVC {
                showArticleTableVC.articleID = articleID
                
                if let userID = UserManager.shared.userIDByArticleID[articleID] {
                    showArticleTableVC.userID = userID
                }
            }
            
            else if segue.identifier == "showUserSegue",
                    let thirdVC = segue.destination as? ThirdViewController {
                if let userID = UserManager.shared.userIDByArticleID[articleID] {
                    thirdVC.userID = userID
                    thirdVC.isFromFirstVC = true
                }
            }
        }
    }

    // MARK: - End editing
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

//MARK: - UISearchBarDelegate
extension FirstViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        prepareForSearch()
        
        let group = DispatchGroup()
        let minimumShowTime = DispatchTime.now() + 0.5
        
        ArticleNetworkManager.shared.searchArticles(keyword: searchText) { result, statusCode, error in
            if let error = error {
                self.handleSearchError(error)
                return
            }
            
            if let articles = result?.articles {
                self.processSearchResults(articles, group: group, searchText: searchText)
                
                group.notify(queue: .main) {
                    self.finalizeSearch(minimumShowTime: minimumShowTime)
                }
            } else {
                self.handleNoSearchResults(minimumShowTime: minimumShowTime)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func prepareForSearch() {
        mbProgressHUD(text: "搜尋中...")
        firstTableView.isHidden = true
    }
    
    private func handleSearchError(_ error: Error) {
        assertionFailure("Search article error: \(error)")
    }
    
    private func processSearchResults(_ articles: [Articles], group: DispatchGroup, searchText: String) {
        ArticleManager.shared.allArticle = articles
        lastSearchKeyword = searchText
        lastSearchResults = articles
        UserManager.shared.userByArticle.removeAll()
        
        for article in articles {
            group.enter()
            UserNetworkManager.shared.getUserByArticleID(articleID: article.article_id) { result, statusCode, error in
                if let users = result?.user {
                    self.firstTableView.animatedIndexPaths.removeAll()
                    UserManager.shared.userByArticle.append(users)
                }
                group.leave()
            }
        }
    }
    
    private func finalizeSearch(minimumShowTime: DispatchTime) {
        DispatchQueue.main.asyncAfter(deadline: minimumShowTime) {
            self.hideProgressedHUD()
            self.firstTableView.isHidden = false
            self.noResultsLabel.isHidden = true
            self.firstTableView.tableFooterView = nil
            self.firstTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            self.firstTableView.reloadData()
        }
    }
    
    private func handleNoSearchResults(minimumShowTime: DispatchTime) {
        DispatchQueue.main.asyncAfter(deadline: minimumShowTime) {
            ArticleManager.shared.allArticle = []
            self.lastSearchKeyword = nil
            self.lastSearchResults = nil
            UserManager.shared.userByArticle.removeAll()
            self.hideProgressedHUD()
            self.firstTableView.isHidden = false
            self.noResultsLabel.isHidden = false
            self.firstTableView.tableFooterView = self.noResultsLabel
            self.firstTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            self.firstTableView.reloadData()
        }
    }
}


