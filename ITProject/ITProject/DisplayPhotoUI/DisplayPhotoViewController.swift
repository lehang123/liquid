//
//  DisplayPhotoViewController.swift
//  ITProject
//
//  Created by Gong Lehan on 22/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import FaveButton
import Firebase
import UIKit

// todo : make the scorll back to the top while click on the header
class DisplayPhotoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, FaveButtonDelegate {
    private static let likeWatchedBookmarkTableViewCell = "LikeWatchedBookmarkCell"
    private static let commentTableViewCell = "CommentCell"

    private static let HEADER_MIN_HEIGHT = UIScreen.main.bounds.height * 0.4
    private static let LIKES_ROW_HEIGHT = UIScreen.main.bounds.height * 0.05
    private static let COMMENT_ROW_HEIGHT = UIScreen.main.bounds.height * 0.05

    private static let LIKE_WATACHED_CELL_LENGTH = 1
    //    private static let EXPAND_COLLPASE_CELL_LENGTH = 1

    private struct CommentCellStruct {
        var comment = String()
        var username = String()
    }

    /* source is the total number of comments */
    private var commentsSource = [CommentCellStruct]()
    /* list is the total number of comments to display */
    //    private var commentCellsList = [CommentCellStruct]()
    //    private var hasHiddenCells = false

    private var photoUID: String!
    private var photoDetail: PhotoDetail!

    public func setPhotoDetailData(photoDetail: PhotoDetail) {
        self.photoDetail = photoDetail
        fillCommentSource()
    }

    public func fillCommentSource() {
        let currSrc: [PhotoDetail.comment]? = photoDetail.getComments()

        currSrc?.forEach { item in
            commentsSource.append(DisplayPhotoViewController.CommentCellStruct(
                comment: item.message ?? "",
                username: item.username ?? ""
            ))
        }
    }

    private var headerView: UIView!
    private var updateHeaderlayout: CAShapeLayer!

    private let headerHeight: CGFloat = UIScreen.main.bounds.height * 0.6
    private let headerCut: CGFloat = 0
    private var cell0Info: LikeWatchedBookmarkCell!

    //    private var tableView_cell_length = 0

    @IBOutlet var displayPhotoImageView: UIImageView!

    @IBOutlet var cmmentText: UITextField!

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        print("DisplayPhotoViewController : view did loaded ")
        super.viewDidLoad()

        // makeDummyCommentSource(num: 20)

        tableView.delegate = self
        tableView.dataSource = self

        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        cmmentText.delegate = self

        setUpTableViewHeader()

        // first one (1 +) for like, watched cell + list length (but when the list is too long, we are going to hide it and expand view appear)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func textFieldShouldEndEditing(_: UITextField) -> Bool {
        print("textFieldShouldEndEditing : aaa")
        return true
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        print("textFieldShouldReturn : aaa")
        return true
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if cmmentText.isEditing {
                if view.frame.origin.y == 0 {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.view.frame.origin.y -= keyboardSize.height
                    })
                }
            }
        }
    }

    @objc func keyboardWillHide(notification _: NSNotification) {
        if view.frame.origin.y != 0 {
            UIView.animate(withDuration: 0.25, animations: {
                self.view.frame.origin.y = 0
            })
        }
    }

    // Enter comment here
    @IBAction func EnterComment(_: Any) {
        cmmentText.endEditing(true)

        let username = Auth.auth().currentUser?.displayName ?? "UNKNOW GUY"
        if cmmentText.text!.count != 0 {
            storeCommentToServer(username: username, comment: cmmentText.text!, photoUID: photoDetail.getUID())
            cmmentText.text = ""
        }
        // todo : pull latest comment from the server, and update comment source

        updateCommentSource()
    }

    private func updateCommentSource() {
        // pull new comment from the server

        var indexPaths = [IndexPath]()

        tableView.beginUpdates()

        //        print("COUNT IS: " ,commentsSource.count)
        indexPaths.append(IndexPath(row: commentsSource.count, section: 0))

        tableView.insertRows(at: indexPaths, with: .top)
        tableView.endUpdates()
        tableView.scrollToRow(at: IndexPath(row: commentsSource.count, section: 0), at: .bottom, animated: true)
        tableView.reloadData()
    }

    // ASSUME : YOU NOT GONNA NEED TO RETRIEVE THESE AGAIN RELATIVE TO CERTAIN USER:
    private func storeCommentToServer(username: String, comment: String, photoUID: String) {
        AlbumDBController.getInstance().UpdateComments(username: username, comment: comment, photoUID: photoUID)
        commentsSource.append(DisplayPhotoViewController.CommentCellStruct(comment: comment, username: username))
    }

    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let controller = storyboard!.instantiateViewController(withIdentifier: "ShowDetailPhotoViewController") as! ShowDetailPhotoViewController
        controller.selectedImage = imageView.image
        present(controller, animated: true)
    }

    @objc func scrollBackToTop(sender: UITapGestureRecognizer) {
        // make sure sender is not nil
        guard sender.view != nil else { return }
        if sender.state == .ended { // when touches end, scroll to top
            let topIndex = IndexPath(row: 0, section: 0)
            tableView.scrollToRow(at: topIndex, at: .top, animated: true)
            cmmentText.endEditing(true)
        }
    }

    func scrollViewDidScroll(_: UIScrollView) {
        tableView.Setupnewview(headerView: headerView, updateHeaderlayout: updateHeaderlayout, headerHeight: headerHeight, headerCut: headerCut, headerStopAt: CGFloat(DisplayPhotoViewController.HEADER_MIN_HEIGHT))
    }

    // MARK: - Table view data source

    // todo: only one for now, afterward, there is a way to expand a comment
    func numberOfSections(in _: UITableView) -> Int {
        // return the number of sections
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        print("numberOfRowsInSection : how often do you called ?")
        // return the number of rows
        return commentsSource.count + DisplayPhotoViewController.LIKE_WATACHED_CELL_LENGTH
    }

    // To do for gillbert
    @objc func liketapFunction(sender _: UITapGestureRecognizer) {
        print("like tap working")
        // sender.
        // cell.likeNumbers.text = cell.likeNumbers!.text!

        let cell = tableView.dequeueReusableCell(withIdentifier: DisplayPhotoViewController.likeWatchedBookmarkTableViewCell) as! LikeWatchedBookmarkCell

        // To do
        // Store the number of likes here and check if this photo has been watched or liked by current user
        // if (not watched)
        cell.likeNumbers.text = String((Int(cell.likeNumbers.text!)!) + 1)
        // else (watched)
        cell.likeNumbers.text = String((Int(cell.likeNumbers.text!)!) - 1)
        //
    }

    // To do
    // Need to create another ui for store bookmark photo
    @objc func bookmarktapFunction(sender _: UITapGestureRecognizer) {
        print("book mark tap working")
    }

    func faveButton(_: FaveButton, didSelected selected: Bool) {
        if selected {
            cell0Info.likeNumbers.text = "1"

        } else {
            cell0Info.likeNumbers.text = "0"
        }
    }

    func getCellInfo(cell: LikeWatchedBookmarkCell) {
        cell0Info = cell
    }

    /* the row only get call when it's visible on the screeen in order to save memory */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 { // like, watched cell. always there
            let cell0 = tableView.dequeueReusableCell(withIdentifier: DisplayPhotoViewController.likeWatchedBookmarkTableViewCell, for: indexPath) as! LikeWatchedBookmarkCell

            // add like button animation
            cell0.likeButton.setSelected(selected: true, animated: false)

            cell0.likeButton.setSelected(selected: false, animated: false)
            cell0.likeButton.delegate = self
            getCellInfo(cell: cell0)

            let bookmarktap = UITapGestureRecognizer(target: self, action: #selector(bookmarktapFunction(sender:)))
            cell0.Bookmark.isUserInteractionEnabled = true
            cell0.Bookmark.addGestureRecognizer(bookmarktap)

            cell0.selectionStyle = UITableViewCell.SelectionStyle.none

            // TO DO GILLBERT
            // LOAD THE likeNumbers and watched numbers
            //cell0.likeNumbers.text = String(photoDetail.getLikes())
            cell0.likeNumbers.text = "9"
            cell0.watchedNumbers.text = String(photoDetail.getWatch())

            return cell0
        } else {
            // create comment cell
            // show the comments, if there are hidden cells, show expandsion cell in the last cell

            let cell1 = tableView.dequeueReusableCell(withIdentifier: DisplayPhotoViewController.commentTableViewCell, for: indexPath) as! CommentCell
            cell1.setUsernameLabel(username: commentsSource[indexPath.row - 1].username)
            cell1.setCommentLabel(comment: commentsSource[indexPath.row - 1].comment)

            cell1.selectionStyle = UITableViewCell.SelectionStyle.none

            return cell1
        }
    }


    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return DisplayPhotoViewController.LIKES_ROW_HEIGHT
        } else {
            return UITableView.automaticDimension
        }
    }

    private func makeDummyCommentSource(num: Int) {
        for i in 1 ... num {
            var commentCell = CommentCellStruct()
            commentCell.comment = "mkk" + String(i)
            commentCell.username = "username" + String(i)
            commentsSource.append(commentCell)
        }
    }

    /* the header that shows to image */
    private func setUpTableViewHeader() {
        /* test on read file for local file */
        Util.GetImageData(imageUID: photoDetail.getUID(), UIDExtension: Util.EXTENSION_JPEG, completion: {
            data in
            self.displayPhotoImageView.image = UIImage(data: data!)
        })
        headerView = tableView.tableHeaderView
        updateHeaderlayout = CAShapeLayer()

        tableView.UpdateView(headerView: headerView, updateHeaderlayout: updateHeaderlayout, headerHeight: headerHeight, headerCut: headerCut)

        let headerViewGesture = UITapGestureRecognizer(target: self, action: #selector(scrollBackToTop))
        let zoomInGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        zoomInGesture.numberOfTapsRequired = 2

        /* note: GestureRecognizer will be disable while tableview is scrolling */
        headerView.addGestureRecognizer(headerViewGesture)
        displayPhotoImageView.addGestureRecognizer(zoomInGesture)
    }

    //    private func initCommentCellsList(){
    //
    //        // load at most 5 comments from caches
    //        if (commentsSource.count != 0) {
    //            for i in 1...min(DisplayPhotoViewController.MAXIMUM_INIT_LIST_LENGTH, commentsSource.count) {
    //                addCommentCellToList( commentStruct: commentsSource[i-1])
    //            }
    //        }
    //    }

    //    private func addCommentCellToList(commentStruct: CommentCellStruct){
    //        commentCellsList.append(commentStruct)
    //        // tableView_cell_length = 1 + commentCellsList.count
    //        tableView_cell_length = commentCellsList.count
    //    }
    //
    //    private func addCommentCellToList(username: String, comment: String){
    //        var commentCell = CommentCellStruct()
    //        commentCell.comment = comment
    //        commentCell.username = username
    //        commentCellsList.append(commentCell)
    //        // tableView_cell_length = 1 + commentCellsList.count
    //        tableView_cell_length = commentCellsList.count
    //    }
    //
    //    private func removeLastCommentCellsFromList(numOfCells : Int){
    //        commentCellsList.removeLast(numOfCells)
    //        tableView_cell_length = tableView_cell_length - numOfCells
    //    }

    // Override to support conditional editing of the table view.
    func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    //    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    //        if editingStyle == .delete {
    //            // Delete the row from the data source
    //            tableView.deleteRows(at: [indexPath], with: .fade)
    //        } else if editingStyle == .insert {
    //            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    //        }
    //    }

    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

     }
     */

    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}
