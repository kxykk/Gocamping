//
//  ViewController.swift
//  Gocamping
//
//  Created by 康 on 2023/7/24.
//

import UIKit
import Network
import MBProgressHUD


class FirstViewController: UIViewController {
    
    @IBOutlet weak var searchArticlesBar: UISearchBar!
    @IBOutlet weak var firstTableView: FirstTableView!
    var noResultsLabel: UILabel!
    let tableViewContainer = UIView()
    var lastSearchKeyword: String?
    var lastSearchResults: [Articles]?
    private var searchTimer: Timer?
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
//        self.firstTableView.isHidden = true
        self.getAllArticle()
    }

    // MARK: - Initial Setup
    private func initialSetup() {
        setupSearchBar()
        setupTableViewContainer()
        setupTableView()
        setupNoResultsLabel()
        setupViewControllerBackground()
        setupMBProgressHUB()
    }
    
    private func setupSearchBar() {
        searchArticlesBar.backgroundImage = UIImage()
        searchArticlesBar.searchTextField.backgroundColor = .white
        searchArticlesBar.searchTextField.layer.borderWidth = 0.0
        searchArticlesBar.shadow()
        searchArticlesBar.delegate = self
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
        disableTrace()
    }
    
    private func setupNoResultsLabel() {
        noResultsLabel = firstTableView.addNoResultsLabel(withText: "無搜尋結果")
    }
    
    private func setupViewControllerBackground() {
        self.view.backgroundColor = UIColor.lightGreen
    }
    
    private func setupMBProgressHUB() {
        self.mbProgressHUD(text: "載入中...")
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
        ArticleNetworkManager.shared.getAllArticleIDandTitle { [weak self] result, statusCode, error in
            guard let self = self else { return }
            guard let articles = result?.articles else { return }
            disableTrace()
            
            ArticleManager.shared.allArticle = articles
            for article in articles {
                group.enter()
                self.fetchUsersByArticleID(article: article, group: group)
            }
            
            group.leave()
        }
    }
    
    // MARK: - Get user infos
    private func fetchUsersByArticleID(article: Articles, group: DispatchGroup) {
        UserNetworkManager.shared.getUserByArticleID(articleID: article.article_id) { [weak self] result, statusCode, error in
            guard let self = self else { return }
            guard let user = result?.user else { return }
            
            UserManager.shared.userObjectByArticleID[article.article_id] = user
            UserManager.shared.userIDByArticleID[article.article_id] = user.user_id
            
            group.leave()
        }
    }
    
    // MARK: - Check network
    private func monitorNetwork() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            if path.status != .satisfied {
                DispatchQueue.main.async {
                    ShowMessageManager.shared.showAlert(on: self, title: "網路連接失敗", message: "請檢查您的網絡設置")
                }
            }
        }
        monitor.start(queue: .global(qos: .background))
    }

    
    // MARK: - Notifications
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(userDidLogout), name: Notification.Name("UserDidLogout"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userDidDelete), name: Notification.Name("UserDidDelete"), object: nil)
    }
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = self.firstTableView.indexPathForSelectedRow else { return }
        let articleIndex = indexPath.row / 2
        let articleID = ArticleManager.shared.allArticle[articleIndex].article_id
        guard let userID = UserManager.shared.userIDByArticleID[articleID] else { return }
        
        switch segue.identifier {
        case "showArticleSegue":
            configureShowArticleSegue(with: segue.destination, articleID: articleID, userID: userID)
        case "showUserSegue":
            configureShowUserSegue(with: segue.destination, articleID: articleID, userID: userID)
        default:
            break
        }
    }

    private func configureShowArticleSegue(with destination: UIViewController, articleID: Int, userID: Int) {
        guard let showArticleTableVC = destination as? ShowArticleTableVC else { return }
        showArticleTableVC.articleID = articleID
        showArticleTableVC.userID = userID
    }

    private func configureShowUserSegue(with destination: UIViewController, articleID: Int, userID: Int) {
        guard let thirdVC = destination as? ThirdViewController else { return }
        thirdVC.userID = userID
        thirdVC.isFromFirstVC = true
    }


    // MARK: - End editing
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Remove notification
    deinit {
        NotificationCenter.default.removeObserver(self)
        searchTimer?.invalidate()
    }

}

//MARK: - UISearchBarDelegate
extension FirstViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTimer?.invalidate()
        disableTrace()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { [weak self] _ in
            self?.executeSearch(searchText: searchText)
        }
    }
    
    private func executeSearch(searchText: String) {
        prepareForSearch()
        
        let group = DispatchGroup()
        let minimumShowTime = DispatchTime.now() + 0.25
        ArticleNetworkManager.shared.searchArticles(keyword: searchText) { [weak self] result, statusCode, error in
            guard let self = self else { return }
            guard let articles = result?.articles else {
                self.handleNoSearchResults(minimumShowTime: minimumShowTime)
                return
            }
            self.processSearchResults(articles, group: group, searchText: searchText)
            group.notify(queue: .main) {
                self.finalizeSearch(minimumShowTime: minimumShowTime)
            }
            
        }
    }
    
    // MARK: - Helper Methods
    private func prepareForSearch() {
        mbProgressHUD(text: "搜尋中...")
        firstTableView.isHidden = true
    }

    private func processSearchResults(_ articles: [Articles], group: DispatchGroup, searchText: String) {
        ArticleManager.shared.allArticle = articles
        lastSearchKeyword = searchText
        lastSearchResults = articles
        UserManager.shared.userByArticle.removeAll()
        
        for article in articles {
            group.enter()
            UserNetworkManager.shared.getUserByArticleID(articleID: article.article_id) { [weak self] result, statusCode, error in
                guard let self = self,
                      let users = result?.user else { return }
                
                self.firstTableView.animatedIndexPaths.removeAll()
                UserManager.shared.userByArticle.append(users)
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
            self.firstTableView.reloadData()
        }
    }
}


