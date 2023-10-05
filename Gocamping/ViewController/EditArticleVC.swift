//
//  EditArticleVC.swift
//  Gocamping
//
//  Created by 康 on 2023/8/8.
//

import UIKit


class EditArticleVC: UIViewController, EditArticleDelegate {
    
    @IBOutlet weak var containerTableView: UIView!
    
    var articleID = 0
    var articleFromEdit: Articles?
    var isFromEdit = false
    var editTableViewController: EditArticleTableVC?
    var contents = [Content]()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViewController()
    }

    // MARK: - Initial setup
    private func setupChildViewController() {
        for child in children {
            if let childVC = child as? EditArticleTableVC {
                editTableViewController = childVC
                editTableViewController?.editArticleDelegate = self
            }
        }
    }
    
    //MARK: - Button actions
    @IBAction func addImageBtnPressed(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = editTableViewController
        present(imagePicker, animated: true)
        
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        finalcontents()
        
        if !isFromEdit {
            postContents()
        } else {
            updateContents()
        }
        
    }
    // MARK: - Post or update article contents
    private func finalcontents() {
        editTableViewController?.editArticleDelegate = self
        if let updatedContents = editTableViewController?.contents {
            self.contents = updatedContents
        }
    }
    
    private func postContents() {
        let articleID = ArticleManager.shared.createArticleID
        NetworkManager.shared.postContent(articleID: articleID, contents: contents) { result, status, error in
            if let error = error {
                ShowMessageManager.shared.showToastGlobal(message: "新增文章內容失敗！")
                return
            }
            NotificationCenter.default.post(name: Notification.Name("postContentSuccess"), object: nil)
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

    private func updateContents() {
        NetworkManager.shared.updateArticleContent(articleID: articleID, newContent: contents) { result, statusCode, error in
            if let error = error {
                ShowMessageManager.shared.showToastGlobal(message: "更新文章內容失敗！")
                return
            }
            NotificationCenter.default.post(name: Notification.Name("editContentSuccess"), object: nil)
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    // MARK: - End editing
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
            
     // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSegue",
           let editArticleTableVC = segue.destination as? EditArticleTableVC{
            if isFromEdit {
                editArticleTableVC.articleID = articleID
                editArticleTableVC.isFromEdit = true
            } else {
                editArticleTableVC.articleID = ArticleManager.shared.createArticleID
            }
        }
    }
    //MARK: - Contents update
    func updateContents(_ contents: [Content]) {
        self.contents = contents
    }
}
protocol EditArticleDelegate: AnyObject {
    func updateContents(_ contents: [Content])
}

