//
//  EditArticleTableVC.swift
//  Gocamping
//
//  Created by 康 on 2023/8/25.
//

import UIKit

class EditArticleTableVC: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    var articleContents = [CombinedItem]()
    var contents = [Content]()
    var sortedContentsDict: [Int: Content] = [:]
    
    var activeTextView: UITextView?
    weak var delegate: UITextViewDelegate?
    weak var editArticleDelegate: EditArticleDelegate?
    
    var isFromEdit = false
    var articleID = 0
    
    enum CombinedItemType: String {
        case text = "text"
        case image = "image"
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    // MARK: - Initial setup
    private func initialSetup() {
        setShowAlert()
        setTableView()
        setDelegate()
        addLongPressGesture()
        addEndEditingGesture()
        initContent()
    }
    
    private func setShowAlert() {
        let title = "提醒"
        let message = "若是需要刪除照片，請長按照片！"
        ShowMessageManager.shared.showAlert(on: self, title: title, message: message)
    }
    
    private func setTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
    }
    
    private func setDelegate() {
        delegate = self
        editArticleDelegate = self
    }
    
    private func addEndEditingGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTableTap))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
    }
    
    private func addLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        self.view.addGestureRecognizer(longPressGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextCell {
            cell.articleTextView.becomeFirstResponder()
        }
    }
    
    private func initContent() {
        if isFromEdit {
            ArticleNetworkManager.shared.getDetailsByArticleID(articleID: articleID) { result, statusCode, error in
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
        } else { // !isFromEdit
            contents = [.text("")]
        }
    }
    
    // MARK: - Append combinedItem
    private func appendCombinedItemToContents(combinedItems: [CombinedItem]) {
        for combinedItem in combinedItems {
            appendIndividualItem(combinedItem: combinedItem)
        }
        self.reorderContentsAndReload()
    }
    
    private func appendIndividualItem(combinedItem: CombinedItem) {
        let sortNumber = combinedItem.sortNumber
        switch combinedItem.type {
        case CombinedItemType.text.rawValue:
            if let content = combinedItem.item.content {
                self.sortedContentsDict[sortNumber] = .text(content)
            }
        case CombinedItemType.image.rawValue:
            guard let imageURL = combinedItem.item.imageURL else {
                return
            }
            self.downloadCombinedImage(imageURL: imageURL, sortNumber: sortNumber)
        default:
            print("未知的類型: \(combinedItem.type)")
        }
    }
    
    private func downloadCombinedImage(imageURL: String, sortNumber: Int) {
        ImageNetworkManager.shared.downloadOrLoadImage(imageURL: imageURL) { data, error in
            if let data = data, let image = UIImage(data: data) {
                self.sortedContentsDict[sortNumber] = .image(image)
                self.reorderContentsAndReload()
            }
        }
    }

    private func reorderContentsAndReload() {
        self.contents = sortedContentsDict.sorted(by: { $0.key < $1.key }).map { $0.value }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellForRow(with: tableView, at: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRow(with: tableView, at: indexPath)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func cellForRow(with tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        switch contents[indexPath.row] {
        case .text(let text):
            return configureTextCell(text: text, at: indexPath)
        case .image(let image):
            return configureImageCell(image: image, at: indexPath)
        }
    }
    
    private func configureTextCell(text: String, at indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath) as! TextCell
        cell.articleTextView.text = text
        cell.articleTextView.delegate = self
        return cell
    }
    
    private func configureImageCell(image: UIImage, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImageCell
        cell.articleImageView?.image = image
        return cell
    }
    
    private func heightForRow(with tableView: UITableView, at indexPath: IndexPath) -> CGFloat {
        switch contents[indexPath.row] {
        case .text(_ ):
            return CGFloat(Int(UITableView.automaticDimension))
        case .image(_ ):
            return 160
        }
    }


    //MARK: - Image function
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // Get activate textView and check indexPath
            if let activeTextView = activeTextView,
               let cell = activeTextView.superview?.superview as? UITableViewCell,
               let indexPath = tableView.indexPath(for: cell) {
                insertImageAndText(at: indexPath, with: pickedImage)
            } else {
                // Other situation
                insertImageAndText(at: nil, with: pickedImage)
            }

            picker.dismiss(animated: true) {
                if let cell = self.tableView.cellForRow(at: IndexPath(row: self.contents.count - 1 , section: 0)) as? TextCell {
                    cell.articleTextView.becomeFirstResponder()
                }
            }
        }
    }
    
    // MARK: - Insert Image and Text
    private func insertImageAndText(at indexPath: IndexPath?, with image: UIImage) {
        if let indexPath = indexPath {
            handleInsertionWithExistingIndexPath(indexPath: indexPath, image: image)
        } else {
            handleInsertionWithoutIndexPath(image: image)
        }
        
        appendEmptyTextIfNeeded()
        
        tableView.reloadData()
    }

    // MARK: - Handle Insertion with Existing IndexPath
    private func handleInsertionWithExistingIndexPath(indexPath: IndexPath, image: UIImage) {
        if case .text(let text) = contents[indexPath.row] {
            let (upperText, lowerText) = splitTextBasedOnSelection(text: text)
            
            // Update current text cell with upperText
            contents[indexPath.row] = .text(upperText)
            
            // Insert lowerText if it is not empty
            if !lowerText.isEmpty {
                insertLowerText(lowerText: lowerText, at: indexPath.row + 2)
            }
            
            // Insert image
            contents.insert(.image(image), at: indexPath.row + 1)
        }
    }

    // MARK: - Handle Insertion without IndexPath
    private func handleInsertionWithoutIndexPath(image: UIImage) {
        contents.append(.image(image))
    }

    // MARK: - Split Text Based on Selection in TextView
    private func splitTextBasedOnSelection(text: String) -> (String, String) {
        let range = activeTextView?.selectedRange ?? NSRange(location: 0, length: 0)
        let upperText = String(text.prefix(upTo: text.index(text.startIndex, offsetBy: min(text.count, range.location))))
        var lowerText = String(text.suffix(from: text.index(text.startIndex, offsetBy: min(text.count, range.location))).trimmingCharacters(in: .whitespacesAndNewlines))
        if lowerText.first == "\n" {
            lowerText.removeFirst()
        }
        return (upperText, lowerText)
    }

    // MARK: - Insert Lower Text
    private func insertLowerText(lowerText: String, at index: Int) {
        if index <= contents.count {
            contents.insert(.text(lowerText), at: index)
        } else {
            contents.append(.text(lowerText))
        }
    }

    // MARK: - Append Empty Text If Needed
    private func appendEmptyTextIfNeeded() {
        contents.append(.text(""))
        let index = contents.count - 3
        if case .text(let lastText) = contents[index], lastText.isEmpty {
            contents.remove(at: index)
        }
    }

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Gesture
    @objc func handleTableTap() {
        view.endEditing(true)
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        
        if gesture.state == .began {
            let touchPoint = gesture.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                
                // Check if case .image
                if case .image(_) = self.contents[indexPath.row] {
                    ShowMessageManager.shared.showDeleteAlert(on: self, title: "刪除照片", message: "確定刪除這張照片嗎？") {
                        self.mergeContent(at: indexPath)
                    }
                }
            }
        }
    }
    
    //MARK: - Merge
    private func mergeContent(at indexPath: IndexPath) {
        
        // Remove and delete
        self.contents.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .fade)
        
        // After delete, modify the array
        let prevIndexPath = IndexPath(row: indexPath.row - 1, section: 0)
        let nextIndexPath = IndexPath(row: indexPath.row , section: 0)
        if prevIndexPath.row >= 0, nextIndexPath.row < self.contents.count,
           case .text(let prevText) = self.contents[prevIndexPath.row],
           case .text(let nextText) = self.contents[nextIndexPath.row] {
            
            // Merge
            let mergedText = prevText + "\n" + nextText
            self.contents[prevIndexPath.row] = .text(mergedText)
            
            // After merge, remove nextIndexPath
            self.contents.remove(at: nextIndexPath.row)
            self.tableView.deleteRows(at: [nextIndexPath], with: .fade)
            
            self.tableView.reloadData()
        }
    }

}

// MARK: - Extension for delegate
extension EditArticleTableVC: UITextViewDelegate {
    
    // MARK: - Text
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if let cell = textView.superview?.superview as? UITableViewCell {
            if let indexPath = tableView.indexPath(for: cell){
                if text == "" && textView.text == "" {
                    if contents.count == 1 || indexPath.row == contents.count - 1 {
                        return false
                    } else {
                        contents.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        return true
                    }
                }
            }
        }
        return true
    }
    
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
