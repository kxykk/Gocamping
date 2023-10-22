//
//  SecondViewController.swift
//  Gocamping
//
//  Created by 康 on 2023/7/24.
//

import UIKit

class SecondViewController: UIViewController {
    
    @IBOutlet weak var searchCampsBar: UISearchBar!
    @IBOutlet weak var SecondTableView: SecondTableView!
    
    var noResultsLabel: UILabel!
    let tableViewContainer = UIView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupTableViewContainer()
        setupTableView()
        setupNoResultsLabel()
        fetchCampsData()
        self.view.backgroundColor = UIColor.peachCream
    }
    
    private func setupSearchBar() {
        searchCampsBar.backgroundImage = UIImage()
        searchCampsBar.searchTextField.backgroundColor = .white
        searchCampsBar.searchTextField.layer.borderWidth = 0.0
        searchCampsBar.shadow()
        searchCampsBar.delegate = self
    }
    
    private func setupTableViewContainer() {
        tableViewContainer.frame = CGRect(x: 0, y: searchCampsBar.frame.maxY, width: self.view.bounds.width, height: self.view.bounds.height - searchCampsBar.frame.maxY)
        tableViewContainer.backgroundColor = .clear
        tableViewContainer.shadow()
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
        self.view.bringSubviewToFront(noResultsLabel)
    }
    

    
    // MARK: - Get camps
    private func fetchCampsData() {
        self.mbProgressHUD(text: "載入中...")
        CampNetworkManager.shared.getCamps { result, statusCode, error in
            if let error = error {
                assertionFailure("Get camps error: \(error)")
                return
            }
            if let camps = result?.camps {
                CampManager.shared.camps = camps
                DispatchQueue.main.async {
                    self.hideProgressedHUD()
                    self.SecondTableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - End editing
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: - UISearchBarDelegate
extension SecondViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.mbProgressHUD(text: "搜尋中...")
        SecondTableView.isHidden = true
        let minimumShowTime = DispatchTime.now() + 0.5
        
        CampNetworkManager.shared.searchCamps(keyword: searchText) { result, statusCode, error in
            if let error = error {
                assertionFailure("Search camps error: \(error)")
                return
            }
            if let camps = result?.camps {
                CampManager.shared.camps = camps
                DispatchQueue.main.asyncAfter(deadline: minimumShowTime) {
                    self.hideProgressedHUD()
                    self.SecondTableView.isHidden = false
                    self.noResultsLabel.isHidden = true
                    self.SecondTableView.tableFooterView = nil
                    self.SecondTableView.reloadData()
                }
            }
            if statusCode == 404 {
                DispatchQueue.main.asyncAfter(deadline: minimumShowTime) {
                    CampManager.shared.camps = []
                    self.hideProgressedHUD()
                    self.SecondTableView.isHidden = false
                    self.noResultsLabel.isHidden = false
                    self.SecondTableView.tableFooterView = self.noResultsLabel
                    self.SecondTableView.reloadData()
                }
            }
        }
    }
}

