//
//  EditProfileVC.swift
//  Gocamping
//
//  Created by 康 on 2023/9/13.
//

import UIKit
import Photos

protocol EditProfileDelegate: AnyObject {
    func didUpdateIntroduction(_ introduction: String)
}

class EditProfileVC: UIViewController {
    
    weak var delegate: EditProfileDelegate?
    
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var introTextView: UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let attributedString = NSMutableAttributedString(string: "自我介紹:")
        attributedString.addAttribute(NSMutableAttributedString.Key.underlineStyle,
                                      value: NSUnderlineStyle.single.rawValue,
                                      range: NSRange(location: 0, length: attributedString.length))
        introLabel.attributedText = attributedString
        
        introTextView.layer.borderWidth = 1.0
        introTextView.layer.borderColor = UIColor.gray.cgColor
        introTextView.layer.cornerRadius = 5.0
        
        if let imageURL = UserDefaults.standard.string(forKey: imageURLKey) {
            if let originalImage = CacheManager.shared.load(filename: imageURL),
               let image = UIImage.thumbnail(from: originalImage) {
                profileImageView.image = image
            } else {
                if let originalImage = UIImage(named: "userDefault"),
                   let image = UIImage.thumbnail(from: originalImage) {
                    profileImageView.image = image
                }
            }
        } 
        
        if let introduction = UserDefaults.standard.string(forKey: introductionKey) {
            introTextView.text = introduction
        } else {
            introTextView.text = "請輸入自我介紹..."
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func imagePickerBtnPressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "Image Source?", message: nil, preferredStyle: .alert)
//        let camera = UIAlertAction(title: "相機", style: .default) { action in
//            self.launchPicker(source: .camera)
//        }
        let library = UIAlertAction(title: "從相簿選取", style: .default) { action in
            self.launchPicker(source: .photoLibrary)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
//        alert.addAction(camera)
        alert.addAction(library)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    @IBAction func confirmBtnPressed(_ sender: Any) {
        let userID = UserDefaults.standard.integer(forKey: userIDKey)
        guard let introduction = introTextView.text else {
            return
        }
        NetworkManager.shared.putUserIntroduction(userID: userID, introduction: introduction) { result, statusCode, error in
            if let error = error {
                assertionFailure("Put introduction error: \(error)")
                return
            }
            UserDefaults.standard.set(introduction, forKey: introductionKey)
        }
        delegate?.didUpdateIntroduction(introduction)
        NotificationCenter.default.post(name: NSNotification.Name("userProfileDidUpdate"), object: nil)
        self.navigationController?.popViewController(animated: true)
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
extension EditProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func launchPicker(source: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(source) else {
            assertionFailure("Source type is not avaliavle")
            return
        }
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.mediaTypes = [UTType.image.identifier, UTType.movie.identifier]
        picker.delegate = self
        present(picker,animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let type = info[.mediaType] as? String else {
            assertionFailure("Invalid Media Type.")
            return
        }
        if type == UTType.image.identifier {
            guard let originalImage = info[.originalImage] as? UIImage,
                  let image = originalImage.resize(maxEdge: 1024) else {
                assertionFailure("Invalid UIImage")
                return
            }
            guard let jpgData = image.jpegData(compressionQuality: 0.6) else {
                assertionFailure("Invalid UIImage")
                return
            }
            if let originalImage = UIImage(data: jpgData),
               let image = UIImage.thumbnail(from: originalImage) {
                profileImageView.image = image
            }
            
            let userID = UserDefaults.standard.integer(forKey: userIDKey)
            let imageSortNumber = 0
            let imageType = "user"
            
            NetworkManager.shared.uploadImage(articleID: nil, userID: userID, campID: nil, imageSortNumber: imageSortNumber, imageType: imageType, imageData: jpgData) { result, statusCode, error in
                if let error = error {
                    assertionFailure("Upload Image error: \(error)")
                    return
                }
                if let imageURL = result?.image?.imageURL {
                    UserDefaults.standard.set(imageURL, forKey: imageURLKey)
                    try? CacheManager.shared.save(data: jpgData, filename: imageURL)
                }
            }
            
        } else if type == UTType.movie.identifier {
            guard let url = info[.mediaURL] as? URL else {
                return
            }
            print("Movie: \(url)")
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
