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
import AVFoundation
import AVKit
import Foundation

// todo : make the scorll back to the top while click on the header
class DisplayPhotoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, FaveButtonDelegate, AVAudioPlayerDelegate
{
    private static let likeWatchedBookmarkTableViewCell = "LikeWatchedBookmarkCell"
    private static let commentTableViewCell = "CommentCell"
    private static let descriptionTableViewCell = "DescriptionCell"

    private static let HEADER_MIN_HEIGHT = UIScreen.main.bounds.height * 0.4
    private static let LIKES_ROW_HEIGHT = UIScreen.main.bounds.height * 0.05
    private static let COMMENT_ROW_HEIGHT = UIScreen.main.bounds.height * 0.05
    /// like & watch cell always at index 0
    private static let LIKE_WATCH_CELL = 0

    private static let LIKE_WATACHED_CELL_LENGTH = 1
    //    private static let EXPAND_COLLPASE_CELL_LENGTH = 1

    private struct CommentCellStruct
    {
        var comment = String()
        var username = String()
    }

    /// source is the total number of comments
    private var commentsSource = [CommentCellStruct]()
    /* list is the total number of comments to display */
    //    private var commentCellsList = [CommentCellStruct]()
    //    private var hasHiddenCells = false

    private var mediaUID: String!
    private var mediaDetail: MediaDetail!

    public func setMediaDetailData(mediaDetail: MediaDetail)
    {
        self.mediaDetail = mediaDetail
        self.fillCommentSource()
    }

    public func fillCommentSource()
    {
        let currSrc: [MediaDetail.comment]? = self.mediaDetail.getComments()

        currSrc?.forEach
        { item in
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
    
    var audioPlayer : AVAudioPlayer!
    var isPlaying = false

    @IBOutlet var displayPhotoImageView: UIImageView!

    @IBOutlet var cmmentText: UITextField!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad()
    {
        print("DisplayPhotoViewController : view did loaded ")
        super.viewDidLoad()

        // makeDummyCommentSource(num: 20)

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tableView.rowHeight = UITableView.automaticDimension
        self.cmmentText.delegate = self
        self.sendButton.isUserInteractionEnabled = false

        self.setUpTableViewHeader()

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @IBAction func playAudio(_ sender: Any) {
        if(isPlaying)
         {
             audioPlayer.stop()
             isPlaying = false
         }
         else
         {
            Util.GetLocalFileURL(by: mediaDetail.audioDescriptionUID, type: .audio){
                url in
                self.prepare_play(url: url!)
            }
           
         }
    }
    
    func prepare_play(url: URL)
    {
        do
        {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            isPlaying = true
        }
        catch{
            print("Error")
        }
    }
    
    
    
    func textFieldShouldEndEditing(_: UITextField) -> Bool
    {
        print("textFieldShouldEndEditing : aaa")
        return true
    }

    func textFieldShouldReturn(_: UITextField) -> Bool
    {
        print("textFieldShouldReturn : aaa")
        return true
    }

    @objc func keyboardWillShow(notification: NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        {
            if self.cmmentText.isEditing
            {
                if view.frame.origin.y == 0 {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.view.frame.origin.y -= keyboardSize.height
                    })
                }
            }
        }
    }

    @objc func keyboardWillHide(notification _: NSNotification)
    {
        if view.frame.origin.y != 0 {
            UIView.animate(withDuration: 0.25, animations: {
                self.view.frame.origin.y = 0
            })
        }
    }
    
    /// Disabled the send action if the comment textField is empty
    /// - Parameter textField: comment textField
    /// - Parameter range: character range
    /// - Parameter string: comment
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (cmmentText.text! as NSString).replacingCharacters(in: range, with: string)
        if text.isEmpty {
            sendButton.setImage(UIImage(named: "disableSendIcon"), for: .normal)
         sendButton.isEnabled = false
        } else {
            sendButton.isUserInteractionEnabled = true
         sendButton.isEnabled = true
         sendButton.setImage(UIImage(named: "ableSendIcon"), for: .normal)
        }
         return true
    }

    // Enter comment here
    @IBAction func EnterComment(_: Any)
    {
        self.cmmentText.endEditing(true)

        let username = Auth.auth().currentUser?.displayName ?? "UNKNOW GUY"
        if self.cmmentText.text!.count != 0 {
            self.storeCommentToServer(username: username, comment: self.cmmentText.text!, photoUID: self.mediaDetail.getUID())
            self.cmmentText.text = ""
        }
        // todo : pull latest comment from the server, and update comment source

        self.updateCommentSource()
        
        // disable the button after sending the comment
         sendButton.setImage(UIImage(named: "disableSendIcon"), for: .normal)
        sendButton.isUserInteractionEnabled = false
        
        //        CacheHandler.getInstance().getUserInfo { (username, _, _, error) in
        //            if let error = error {
        //                print("Error in EnterComment: \(error)")
        //            } else {
        //                if (self.cmmentText.text!.count != 0) {
        //                    print ("success enter comment")
        //                    self.addCommentCellToList(username: username!, comment: String(self.cmmentText.text!))
        //                    self.storeCommentToServer(username: username!, comment:  String(self.cmmentText.text!), photoUID: self.photoUID)
        //
        //                    self.tableView.reloadData()
        //                    self.cmmentText.text = ""
        //                }
        //
        //            }
        //        }
    }

    private func updateCommentSource()
    {
        // pull new comment from the server

        var indexPaths = [IndexPath]()

        tableView.beginUpdates()

        //        print("COUNT IS: " ,commentsSource.count)
        indexPaths.append(IndexPath(row: self.commentsSource.count, section: 0))

        self.tableView.insertRows(at: indexPaths, with: .top)
        self.tableView.endUpdates()
        self.tableView.scrollToRow(at: IndexPath(row: self.commentsSource.count, section: 0), at: .bottom, animated: true)
        self.tableView.reloadData()
    }

    private func storeCommentToServer(username: String, comment: String, photoUID: String)
    {
        AlbumDBController.getInstance().UpdateComments(username: username, comment: comment, photoUID: photoUID)
        self.commentsSource.append(DisplayPhotoViewController.CommentCellStruct(comment: comment, username: username))
    }

    @objc func imageTapped(_ sender: UITapGestureRecognizer)
    {
        // todo : play video if it's a video
        
        if mediaDetail.ext.contains(Util.EXTENSION_JPEG)  ||
            mediaDetail.ext.contains(Util.EXTENSION_PNG){
            
            let imageView = sender.view as! UIImageView
                  let controller = storyboard!.instantiateViewController(withIdentifier: "ShowDetailPhotoViewController") as! ShowDetailPhotoViewController
                  controller.selectedImage = imageView.image
                  present(controller, animated: true)
            
        }else if mediaDetail.ext.contains(Util.EXTENSION_M4V) ||
            mediaDetail.ext.contains(Util.EXTENSION_MP4){
            
            let controller = AVPlayerViewController()
            
            Util.GetLocalFileURL(by: mediaDetail.UID, type: .video){
                url in
                DispatchQueue.main.async {
                    controller.player = AVPlayer(url: url!)
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
      
    }

    @objc func scrollBackToTop(sender: UITapGestureRecognizer)
    {
        // make sure sender is not nil
        guard sender.view != nil else { return }
        if sender.state == .ended
        { // when touches end, scroll to top
            let topIndex = IndexPath(row: 0, section: 0)
            tableView.scrollToRow(at: topIndex, at: .top, animated: true)
            self.cmmentText.endEditing(true)
        }
    }

    func scrollViewDidScroll(_: UIScrollView)
    {
        self.tableView.Setupnewview(headerView: self.headerView, updateHeaderlayout: self.updateHeaderlayout, headerHeight: self.headerHeight, headerCut: self.headerCut, headerStopAt: CGFloat(DisplayPhotoViewController.HEADER_MIN_HEIGHT))
    }

    // MARK: - Table view data source

    // todo: only one for now, afterward, there is a way to expand a comment
    func numberOfSections(in _: UITableView) -> Int
    {
        // return the number of sections
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int
    {
        print("numberOfRowsInSection : how often do you called ?")
        // return the number of rows
        return self.commentsSource.count + DisplayPhotoViewController.LIKE_WATACHED_CELL_LENGTH
    }

    

    // To do
    // Need to create another ui for store bookmark photo
    @objc func bookmarktapFunction(sender _: UITapGestureRecognizer)
    {
        print("book mark tap working")
    }
    

    func faveButton(_: FaveButton, didSelected selected: Bool)
    {
            print("faveButton  working")
        if (selected){
            mediaDetail.upLikes()
            cell0Info.likeNumbers.text = String(mediaDetail.getLikesCounter())
        }
        else{
            mediaDetail.DownLikes()
            cell0Info.likeNumbers.text = String(mediaDetail.getLikesCounter())

        }
    }

    func getCellInfo(cell: LikeWatchedBookmarkCell)
    {
        self.cell0Info = cell
    }

    /* the row only get call when it's visible on the screeen in order to save memory */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // manage like &  watched cell
        if indexPath.row == DisplayPhotoViewController.LIKE_WATCH_CELL {
            
            //set cell0 reference to like and watched cell
            let cell0 = tableView.dequeueReusableCell(withIdentifier: DisplayPhotoViewController.likeWatchedBookmarkTableViewCell, for: indexPath) as! LikeWatchedBookmarkCell

            // if already liked previously, turn on the heart:
            if  mediaDetail.hasLiked(){
                cell0.likeButton.setSelected(selected: true, animated: false)

            }
            else{
                cell0.likeButton.setSelected(selected: false, animated: false)

            }

            cell0.likeButton.delegate = self
            self.getCellInfo(cell: cell0)

            let bookmarktap = UITapGestureRecognizer(target: self, action: #selector(self.bookmarktapFunction(sender:)))
            cell0.Bookmark.isUserInteractionEnabled = true
            cell0.Bookmark.addGestureRecognizer(bookmarktap)

            cell0.selectionStyle = UITableViewCell.SelectionStyle.none

            // load the likeNumbers and watched numbers
            cell0.likeNumbers.text = String(self.mediaDetail.getLikesCounter())

            self.mediaDetail.upWatch()

            cell0.watchedNumbers.text = String(self.mediaDetail.getWatch())

            return cell0
        }
        else if (indexPath.row == 1) {
            
            let descriptionCell = self.tableView.dequeueReusableCell(withIdentifier: DisplayPhotoViewController.descriptionTableViewCell, for: indexPath) as! DescriptionCell
            descriptionCell.setDescriptionLabel(description: "TRY HERE wo cao ni ma bi de ri ni ma de xian ren abnban jian zhi jiu shi shabi yige woc ao niaw jdoaiwjd iojwaio joiaj oijwo ijaowij oiawj oiajw ioaj iojawoijaw")
            descriptionCell.selectionStyle = UITableViewCell.SelectionStyle.none
            return descriptionCell

        }
        else {
            // create comment cell
            // show the comments, if there are hidden cells, show expandsion cell in the last cell

            let cell1 = tableView.dequeueReusableCell(withIdentifier: DisplayPhotoViewController.commentTableViewCell, for: indexPath) as! CommentCell
            cell1.setUsernameLabel(username: self.commentsSource[indexPath.row - 1].username)
            cell1.setCommentLabel(comment: self.commentsSource[indexPath.row - 1].comment)

            cell1.selectionStyle = UITableViewCell.SelectionStyle.none

            return cell1
        }
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == 0 {
            return DisplayPhotoViewController.LIKES_ROW_HEIGHT
        } else if indexPath.row == 1 {
            return DisplayPhotoViewController.LIKES_ROW_HEIGHT*2
        }
        else {
            return UITableView.automaticDimension
        }
    }

    private func makeDummyCommentSource(num: Int)
    {
        for i in 1 ... num
        {
            var commentCell = CommentCellStruct()
            commentCell.comment = "mkk" + String(i)
            commentCell.username = "username" + String(i)
            self.commentsSource.append(commentCell)
        }
    }

    /// the header that shows to image
    private func setUpTableViewHeader()
    {
        /* test on read file for local file */
        Util.GetImageData(imageUID: self.mediaDetail.getUID(), UIDExtension: Util.EXTENSION_JPEG, completion: {
            data in
            self.displayPhotoImageView.image = UIImage(data: data!)
        })
        self.headerView = self.tableView.tableHeaderView
        self.updateHeaderlayout = CAShapeLayer()

        self.tableView.UpdateView(headerView: self.headerView, updateHeaderlayout: self.updateHeaderlayout, headerHeight: self.headerHeight, headerCut: self.headerCut)

        let headerViewGesture = UITapGestureRecognizer(target: self, action: #selector(self.scrollBackToTop))
        let zoomInGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
        zoomInGesture.numberOfTapsRequired = 2

        /* note: GestureRecognizer will be disable while tableview is scrolling */
        self.headerView.addGestureRecognizer(headerViewGesture)
        self.displayPhotoImageView.addGestureRecognizer(zoomInGesture)
    }
    


    // Override to support conditional editing of the table view.
    func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool
    {
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
