//
//  EditArticleTableVC.swift
//  Gocamping
//
//  Created by 康 on 2023/8/25.
//

import UIKit

// isFrom 表編輯狀態，會顯示原本文章內容
class EditArticleTableVC: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    
    var activeTextView: UITextView?
    var articleContents = [CombinedItem]()
    var contents = [Content]()
    var isFromEdit = false
    var articleID = 0
    var contentsDict: [Int: Content] = [:]

    
    weak var delegate: UITextViewDelegate?
    weak var editArticleDelegate: EditArticleDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show alert
        let title = "提醒"
        let message = "若是需要刪除照片，請長按！"
        ShowMessageManager.shared.showAlert(on: self, title: title, message: message)
        
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        
        delegate = self
        editArticleDelegate = self
        
        addLongPressGesture()
        if isFromEdit {
            NetworkManager.shared.getDetailsByArticleID(articleID: articleID) { result, statusCode, error in
                if let error = error {
                    assertionFailure("Get article error: \(error)")
                    return
                }
                if let content = result?.combinedItems {
                    self.articleContents.append(contentsOf: content)
                    self.appendCombinedItemToContents(combinedItems: self.articleContents)
                    DispatchQueue.main.async {
                        if self.contents.count == 0 {
                            self.contents = [.text("")]
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        } else {
            contents = [.text("")]
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTableTap))
        tapGesture.cancelsTouchesInView = false 
        tableView.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextCell {
            cell.articleTextView.becomeFirstResponder()
        }
    }
    
    func appendCombinedItemToContents(combinedItems: [CombinedItem]) {
        for combinedItem in combinedItems {
            let sortNumber = combinedItem.sortNumber
            switch combinedItem.type {
            case "text":
                if let content = combinedItem.item.content {
                    self.contentsDict[sortNumber] = .text(content)
                }
            case "image":
                if let imageURL = combinedItem.item.imageURL {
                    NetworkManager.shared.downloadImage(imageURL: imageURL) { data, error in
                        guard let data = data, let image = UIImage(data: data) else {
                            assertionFailure("image error: \(String(describing: error))")
                            return
                        }
                        DispatchQueue.main.async {
                            self.contentsDict[sortNumber] = .image(image)
                            self.reorderContentsAndReload()
                        }
                    }
                }
            default:
                print("未知的類型: \(combinedItem.type)")
            }
        }
        self.reorderContentsAndReload()
    }

    func reorderContentsAndReload() {
        self.contents = contentsDict.sorted(by: { $0.key < $1.key }).map { $0.value }
        self.tableView.reloadData()
    }
    
    @objc func handleTableTap() {
        view.endEditing(true)
    }



    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch contents[indexPath.row] {
            
            // 如果是textCell
        case .text(let text):
            let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath) as! TextCell
            cell.articleTextView.text = text
            cell.articleTextView.delegate = self
            
            return cell
            // 如果是imageCell
        case .image(let image):
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImageCell
            cell.articleImageView?.image = image
            return cell
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch contents[indexPath.row] {
        case .text(_ ):
            return UITableView.automaticDimension
        case .image(_ ):
            return 160
        }
      
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: Image function
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // 取得正在運作的textView，並確定是在哪個tableViewCell作用
            if let activeTextView = activeTextView,
               let cell = activeTextView.superview?.superview as? UITableViewCell,
               let indexPath = tableView.indexPath(for: cell) {
                insertImageAndText(at: indexPath, with: pickedImage)
            } else {
                // 如果沒有確定在哪邊作用，則插入圖片到最後
                insertImageAndText(at: nil, with: pickedImage)
            }
            
            // 關閉選擇器， 選擇後看最後一個是不是textCell，是的話輸入指摽直接放在這
            picker.dismiss(animated: true) {
                if let cell = self.tableView.cellForRow(at: IndexPath(row: self.contents.count - 1 , section: 0)) as? TextCell {
                    cell.articleTextView.becomeFirstResponder()
                }
            }
        }
    }
    
    //MARK: grsture function
    private func addLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        self.view.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        print("Long press detected!")
        
        if gesture.state == .began {
            let touchPoint = gesture.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {

                    // 確保長按的是 ImageCell
                    if case .image(_) = self.contents[indexPath.row] {
                        ShowMessageManager.shared.showDeleteAlert(on: self, title: "刪除照片", message: "確定刪除這張照片嗎？") {
                            self.contents.remove(at: indexPath.row)
                            self.tableView.deleteRows(at: [indexPath], with: .automatic)
                            
                            
                            // 照片已刪除，現在檢查並合併相鄰的TextCell
                            let prevIndexPath = IndexPath(row: indexPath.row - 1, section: 0)
                            let nextIndexPath = IndexPath(row: indexPath.row , section: 0)
                            if prevIndexPath.row >= 0, nextIndexPath.row < self.contents.count,
                               case .text(let prevText) = self.contents[prevIndexPath.row],
                               case .text(let nextText) = self.contents[nextIndexPath.row] {
                                
                                // 合併上下兩個TextCell的內容
                                let mergedText = prevText + "\n" + nextText
                                self.contents[prevIndexPath.row] = .text(mergedText)
                                
                                // 刪除下方的TextCell
                                self.contents.remove(at: nextIndexPath.row)
                                self.tableView.deleteRows(at: [nextIndexPath], with: .automatic)
                                
                                self.tableView.reloadData()
                            }
                        }
                }
            }
        }
    }
    
    

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func insertImageAndText(at indexPath: IndexPath?, with image: UIImage) {
        if let indexPath = indexPath {
            if case .text(let text) = contents[indexPath.row] {
                let range = activeTextView?.selectedRange ?? NSRange(location: 0, length: 0)
                let upperText = String(text.prefix(upTo: text.index(text.startIndex, offsetBy: min(text.count, range.location))))
                var lowerText = String(text.suffix(from: text.index(text.startIndex, offsetBy: min(text.count, range.location))).trimmingCharacters(in: .whitespacesAndNewlines))
                if lowerText.first == "\n" {
                    lowerText.removeFirst()
                }
                contents[indexPath.row] = .text(upperText)
                if !lowerText.isEmpty {
                    if indexPath.row + 2 <= contents.count {
                        contents.insert(.text(lowerText), at: indexPath.row + 2)
                    } else {
                        contents.append(.text(lowerText))
                    }
                    
                }
                contents.insert(.image(image), at: indexPath.row + 1)
            }
        } else {
            contents.append(.image(image))
        }
        
        contents.append(.text(""))
        
        let index = contents.count - 3
        if case .text(let lastText) = contents[index], lastText.isEmpty {
            contents.remove(at: index)
        }

        tableView.reloadData()
        print(contents)
    }

    
    

    
}



extension EditArticleTableVC: UITextViewDelegate {
    
    // 除了第一個跟最後一個cell 其他可自動刪除
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if let cell = textView.superview?.superview as? UITableViewCell {
            
            if let indexPath = tableView.indexPath(for: cell){
                
                if text == "" && textView.text == "" {
                    if contents.count == 1 || indexPath.row == contents.count - 1 {
                        return false
                    } else {
                        contents.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                        return true
                    }
                }
            }
        }
        return true
    }
    // 有輸入就調整
    func textViewDidChange(_ textView: UITextView) {
        
        if let cell = textView.superview?.superview as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                contents[indexPath.row] = .text(textView.text)
            }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = textView
    }
    
}


extension EditArticleTableVC: EditArticleDelegate {

    func updateContents(_ contents: [Content]) {
        self.contents = contents
    }
}
