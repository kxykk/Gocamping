//
//  SecondViewController.swift
//  Gocamping
//
//  Created by 康 on 2023/7/24.
//

import UIKit
import MBProgressHUD

class SecondViewController: UIViewController {
    
    @IBOutlet weak var searchCampsBar: UISearchBar!
    @IBOutlet weak var SecondTableView: UITableView!
    
    var noResultsLabel: UILabel!
    let tableViewContainer = UIView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        fetchCampsData()
    }
    
    // MARK: - Initial Setup
    private func initialSetup() {
        setupSearchBar()
        setupTableViewContainer()
        setupTableView()
        setupNoResultsLabel()
        setupBackgroundColor()
    }
    
    private func setupSearchBar() {
        searchCampsBar.backgroundImage = UIImage()
        searchCampsBar.searchTextField.backgroundColor = .white
        searchCampsBar.searchTextField.layer.borderWidth = 0.0
        searchCampsBar.delegate = self
    }
    
    private func setupTableViewContainer() {
        tableViewContainer.frame = CGRect(x: 0, y: searchCampsBar.frame.maxY, width: self.view.bounds.width, height: self.view.bounds.height - searchCampsBar.frame.maxY)
        self.view.addSubview(tableViewContainer)
    }
    
    private func setupTableView() {
        SecondTableView.frame = tableViewContainer.bounds
        SecondTableView.layer.cornerRadius = 10
        SecondTableView.clipsToBounds = true
        tableViewContainer.addSubview(SecondTableView)
    }
    
    private func setupNoResultsLabel() {
        noResultsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: SecondTableView.bounds.width, height: 50))
        noResultsLabel.text = "無搜尋結果"
        noResultsLabel.textAlignment = .center
        noResultsLabel.textColor = .gray
        noResultsLabel.isHidden = true
        SecondTableView.addSubview(noResultsLabel)
    }
    
    private func setupBackgroundColor() {
        self.view.backgroundColor = UIColor.peachCream
    }
    
    // MARK: - Fetch all camps
    private func fetchCampsData() {
        self.mbProgressHUD(text: "載入中...")
        CampNetworkManager.shared.getCamps { [weak self] result, statusCode, error in
            guard let self = self else { return }
            guard let camps = result?.camps else { return }
            disableTrace()
            
            CampManager.shared.camps = camps
            DispatchQueue.main.async {
                self.hideProgressedHUD()
                self.SecondTableView.reloadData()
            }
        }
    }
}

// MARK: - Search camps
extension SecondViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            
        self.mbProgressHUD(text: "搜尋中...")
        SecondTableView.isHidden = true
            
        let minimumShowTime = DispatchTime.now() + 0.5
            
        CampNetworkManager.shared.searchCamps(keyword: searchText) { [weak self] result, statusCode, _ in
            guard let self = self else { return }
            disableTrace()
                
            if let camps = result?.camps {
                DispatchQueue.main.asyncAfter(deadline: minimumShowTime) {
                    self.handleSuccessfulSearch(camps: camps)
                }
            } else if statusCode == 404 {
                DispatchQueue.main.asyncAfter(deadline: minimumShowTime) {
                    self.handleNotFound()
                }
            }
        }
    }

    // MARK: - Search Successfully
    private func handleSuccessfulSearch(camps: [Camp]) {
        CampManager.shared.camps = camps
        self.hideProgressedHUD()
        self.SecondTableView.isHidden = false
        self.noResultsLabel.isHidden = true
        self.SecondTableView.reloadData()
    }

    // MARK: - Search Fail
    private func handleNotFound() {
        CampManager.shared.camps = []
        self.hideProgressedHUD()
        self.SecondTableView.isHidden = false
        self.noResultsLabel.isHidden = false
        self.SecondTableView.reloadData()
    }

}
