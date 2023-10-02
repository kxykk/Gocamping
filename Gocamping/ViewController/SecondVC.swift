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
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Label
        noResultsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: SecondTableView.bounds.width, height: 50))
        noResultsLabel.text = "搜尋不到露營地"
        noResultsLabel.textAlignment = .center
        noResultsLabel.textColor = .gray
        noResultsLabel.isHidden = true
        SecondTableView.addSubview(noResultsLabel)
        self.view.bringSubviewToFront(noResultsLabel)
        
        // Indicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        
        searchCampsBar.delegate = self
        
        activityIndicator.startAnimating()
        NetworkManager.shared.getCamps { result, statusCode, error in
            if let error = error {
                assertionFailure("Get camps error: \(error)")
                return
            }
            if let camps = result?.camps {
                CampManager.shared.camps = camps
                DispatchQueue.main.async {
                    self.SecondTableView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SecondViewController: UISearchBarDelegate {
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        activityIndicator.startAnimating()
        SecondTableView.isHidden = true
        let minimumShowTime = DispatchTime.now() + 0.5
        
        NetworkManager.shared.searchCamps(keyword: searchText) { result, statusCode, error in
            if let error = error {
                assertionFailure("Search camps error: \(error)")
                return
            }
            if let camps = result?.camps {
                CampManager.shared.camps = camps
                DispatchQueue.main.asyncAfter(deadline: minimumShowTime) {
                    self.activityIndicator.stopAnimating()
                    self.SecondTableView.isHidden = false
                    self.noResultsLabel.isHidden = true
                    self.SecondTableView.tableFooterView = nil
                    self.SecondTableView.reloadData()
                }
            }
            if statusCode == 404 {
                DispatchQueue.main.asyncAfter(deadline: minimumShowTime) {
                    CampManager.shared.camps = []
                    self.activityIndicator.stopAnimating()
                    self.SecondTableView.isHidden = false
                    self.noResultsLabel.isHidden = false
                    self.SecondTableView.tableFooterView = self.noResultsLabel
                    self.SecondTableView.reloadData()
                }
            }
        }
    }
}
