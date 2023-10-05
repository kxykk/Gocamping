//
//  CreateArticleVC.swift
//  Gocamping
//
//  Created by 康 on 2023/8/9.
//

import UIKit
import Photos
class CreateArticleVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var imageShow: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    
    var resizedJpgData: Data?
    
    var articleID = 0
    
    // MARK: - Liftcycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imageShow?.contentMode = .scaleAspectFill
    }

    // MARK: - Button aactions
    @IBAction func uploadImageBtnPressed(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    @IBAction func confirmBtnPressed(_ sender: Any) {

        guard let title = titleTextField.text, !title.isEmpty else {
            ShowMessageManager.shared.showAlert(on: self, title: "錯誤", message: "請輸入標題")
            return
        }
        guard imageShow.image != nil else {
            ShowMessageManager.shared.showAlert(on: self, title: "錯誤", message: "請選擇照片")
            return
        }
        if let imageData = resizedJpgData {
            postArticle(title: title, imageData: imageData)
        }
        
    }
    
    // MARK: - Post article
    private func postArticle(title: String, imageData: Data) {
        
        let userID = UserDefaults.standard.integer(forKey: userIDKey)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let createDate = dateFormatter.string(from: Date())

        NetworkManager.shared.postArticle(title: title, userID: userID, createDate: createDate) { result, status, error in
            if let error = error {
                ShowMessageManager.shared.showToastGlobal(message: "創建文章失敗！")
                return
            }
            if let articleID = result?.article?.article_id {
                self.uploadArticleImage(articleID: articleID, imageData: imageData)
            }
        }
    }
    
    private func uploadArticleImage(articleID: Int, imageData: Data) {
        let imageType = "title"
        let imageSortNumber = 0
            NetworkManager.shared.uploadImage(articleID: articleID, userID: nil, campID: nil, imageSortNumber: imageSortNumber, imageType: imageType, imageData: imageData) { result, status, error in
                if let error = error {
                    ShowMessageManager.shared.showToastGlobal(message: "上傳照片失敗！")
                    return
                }
                ArticleManager.shared.createArticleID = articleID
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "createSegue", sender: nil)
                }
        }
    }
    
    // MARK: - Image picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        guard let type = info[ .mediaType] as? String else {
            ShowMessageManager.shared.showToastGlobal(message: "Invalid Media Type")
            return
        }
        if type == UTType.image.identifier  {
            guard let originalImage = info[.originalImage] as? UIImage,
                  let resizeImage = originalImage.resize(maxEdge: 1024) else {
                ShowMessageManager.shared.showToastGlobal(message: "Invalid UIImage")
                return
            }
            resizedJpgData = resizeImage.jpegData(compressionQuality: 0.6)
            
            imageShow.image = resizeImage
            imageShow?.contentMode = .scaleAspectFill
        }
        picker.dismiss(animated: true, completion: nil)

    }
    
    // MARK: - End editing
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createSegue",let editArticleVC = segue.destination as? EditArticleVC {
            editArticleVC.articleID = ArticleManager.shared.createArticleID
        }
    }
}
