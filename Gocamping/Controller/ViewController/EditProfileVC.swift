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
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    // MARK: - Initial setup
    private func initialSetup() {
        let attributedString = NSMutableAttributedString(string: "自我介紹:")
        introLabel.attributedText = attributedString
        
        introTextView.layer.borderWidth = 1.0
        introTextView.layer.borderColor = UIColor.gray.cgColor
        introTextView.layer.cornerRadius = 5.0
        
        setUserImage()
        setUserIntroduction()
    }
    
    private func setUserImage() {
        if let imageURL = UserDefaults.standard.string(forKey: imageURLKey),
            let originalImage = CacheManager.shared.load(filename: imageURL),
            let image = UIImage.thumbnail(from: originalImage) {
            profileImageView.image = image
        } else {
            if let originalImage = UIImage(named: "userDefault"),
               let image = UIImage.thumbnail(from: originalImage) {
                profileImageView.image = image
            }
        }
    }
    
    private func setUserIntroduction() {
        if let introduction = UserDefaults.standard.string(forKey: introductionKey) {
            introTextView.text = introduction
        } else {
            introTextView.text = "請輸入自我介紹..."
        }
    }
    

    // MARK: - Button actions
    @IBAction func imagePickerBtnPressed(_ sender: Any) {
        showAlert()
    }
    
    @IBAction func confirmBtnPressed(_ sender: Any) {
        
        guard let introduction = introTextView.text else {
            return
        }
        updateUserIntroduction(introduction: introduction)
        delegate?.didUpdateIntroduction(introduction)
        NotificationCenter.default.post(name: NSNotification.Name("userProfileDidUpdate"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Pick image alert
    private func showAlert() {
        
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
    
    // MARK: - Update user introduction
    private func updateUserIntroduction(introduction: String) {
        let userID = UserDefaults.standard.integer(forKey: userIDKey)
        
        UserNetworkManager.shared.putUserIntroduction(userID: userID, introduction: introduction) { result, statusCode, error in
            if let error = error {
                ShowMessageManager.shared.showToastGlobal(message: "更改自我介紹失敗！")
                return
            }
            UserDefaults.standard.set(introduction, forKey: introductionKey)
        }
    }
    
    // MARK: - End editing
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
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
                ShowMessageManager.shared.showToastGlobal(message: "Invalid UIImage")
                return
            }
            guard let imageData = image.jpegData(compressionQuality: 0.6) else {
                ShowMessageManager.shared.showToastGlobal(message: "Invalid UIImage")
                return
            }
            if let originalImage = UIImage(data: imageData),
               let image = UIImage.thumbnail(from: originalImage) {
                profileImageView.image = image
                uploadUserImage(imageData: imageData)
            }
        } else if type == UTType.movie.identifier {
            guard let url = info[.mediaURL] as? URL else {
                return
            }
            print("Movie: \(url)")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UPload user image
    private func uploadUserImage(imageData: Data) {
        let userID = UserDefaults.standard.integer(forKey: userIDKey)
        let imageSortNumber = 0
        let imageType = "user"
        
        ImageNetworkManager.shared.uploadImage(articleID: nil, userID: userID, campID: nil, imageSortNumber: imageSortNumber, imageType: imageType, imageData: imageData) { result, statusCode, error in
            if let error = error {
                ShowMessageManager.shared.showToastGlobal(message: "更新照片失敗！")
                return
            }
            if let imageURL = result?.image?.imageURL {
                UserDefaults.standard.set(imageURL, forKey: imageURLKey)
                try? CacheManager.shared.save(data: imageData, filename: imageURL)
            }
        }
    }
    
}
