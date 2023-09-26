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
    var articleID = 0
    
    var resizedJpgData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageShow?.contentMode = .scaleAspectFill
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func uploadImageBtnPressed(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true)
        
    }
    @IBAction func confirmBtnPressed(_ sender: Any) {
        
        //暫時用一個id測試
        let userID = UserDefaults.standard.integer(forKey: userIDKey)
        let imageType = "title"
        let imageSortNumber = 0

        guard let title = titleTextField.text, !title.isEmpty else {
            ShowMessageManager.shared.showAlert(on: self, title: "錯誤", message: "請輸入標題")
            return
        }
        guard imageShow.image != nil else {
            ShowMessageManager.shared.showAlert(on: self, title: "錯誤", message: "請選擇照片")
            return
        }
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: Date())
        
        // 照片傳到指定資料夾
        if let jpgData = resizedJpgData {

                // 創建文章
                NetworkManager.shared.postArticle(title: title, userID: userID, createDate: dateString) { result, status, error in
                    if let error = error {
                        assertionFailure("Post article error: \(error)")
                        return
                    }
                    if let articleID = result?.article?.article_id {
                        NetworkManager.shared.uploadImage(articleID: articleID, userID: nil, campID: nil, imageSortNumber: imageSortNumber, imageType: imageType, imageData: jpgData) { result, status, error in
                            if let error = error {
                                assertionFailure("Upload image error: \(error)")
                                return
                            }
                            DispatchQueue.main.async {
                                ArticleManager.shared.createArticleID = articleID
                                self.performSegue(withIdentifier: "createSegue", sender: nil)
                            }
                        }
                    } else {
                        assertionFailure("未取得articleID: \(String(describing: result))")
                        return
                    }
            }
        }
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("didFinishPickingMediaWithInfo: \(info)")
        
        guard let type = info[ .mediaType] as? String else {
            assertionFailure("Invalid Media Type")
            return
        }
        if type == UTType.image.identifier  {
            guard let originalImage = info[.originalImage] as? UIImage,
                  let resizeImage = originalImage.resize(maxEdge: 1024) else {
                assertionFailure("Invalid UIImage")
                return
            }
            resizedJpgData = resizeImage.jpegData(compressionQuality: 0.6)
            
            imageShow.image = resizeImage
            imageShow?.contentMode = .scaleAspectFill
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "createSegue",let editArticleVC = segue.destination as? EditArticleVC {
            editArticleVC.articleID = ArticleManager.shared.createArticleID
        }
    }
    

}
