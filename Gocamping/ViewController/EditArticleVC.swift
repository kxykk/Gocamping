//
//  EditArticleVC.swift
//  Gocamping
//
//  Created by 康 on 2023/8/8.
//

import UIKit

protocol EditArticleDelegate: AnyObject {
    func updateContents(_ contents: [Content])
}

class EditArticleVC: UIViewController, EditArticleDelegate {
    
    //    @IBOutlet weak var editTableView: EditArticleTableView!
    @IBOutlet weak var containerTableView: UIView!
    
    var articleID = 0
    var articleFromEdit: Articles?
    var isFromEdit = false
    var editTableViewController: EditArticleTableVC?
    var contents = [Content]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        for child in children {
            if let childVC = child as? EditArticleTableVC {
                editTableViewController = childVC
                editTableViewController?.editArticleDelegate = self
                
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: Button
    @IBAction func addImageBtnPressed(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = editTableViewController
        present(imagePicker, animated: true)
        
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        // The final contents
        editTableViewController?.editArticleDelegate = self
        if let updatedContents = editTableViewController?.contents {
            self.contents = updatedContents
        }
        
        if !isFromEdit { // Else from editTableVC.articleID
            let articleID = ArticleManager.shared.createArticleID
            NetworkManager.shared.postContent(articleID: articleID, contents: contents) { result, status, error in
                if let error = error {
                    assertionFailure("Post content error: \(error)")
                    return
                }
                print("articleID = \(self.articleID)")
                NotificationCenter.default.post(name: Notification.Name("postContentSuccess"), object: nil)
                
                self.navigationController?.popToRootViewController(animated: true)
            }
        } else {
            NetworkManager.shared.updateArticleContent(articleID: articleID, newContent: contents) { result, statusCode, error in
                if let error = error {
                    assertionFailure("Update content error: \(error)")
                    return
                }
                NotificationCenter.default.post(name: Notification.Name("editContentSuccess"), object: nil)
                
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
            
    func updateContents(_ contents: [Content]) {
        self.contents = contents
    }
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
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
}
