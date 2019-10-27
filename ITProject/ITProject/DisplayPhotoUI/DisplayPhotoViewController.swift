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

class DisplayPhotoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, FaveButtonDelegate, AVAudioPlayerDelegate
{
    // MARK: - Properties
    private static let likeWatchedBookmarkTableViewCell = "LikeWatchedBookmarkCell"
    private static let commentTableViewCell = "CommentCell"
    private static let descriptionTableViewCell = "DescriptionCell"

    private static let HEADER_MIN_HEIGHT = UIScreen.main.bounds.height * 0.4
    private static let LIKES_ROW_HEIGHT = UIScreen.main.bounds.height * 0.05
    private static let COMMENT_ROW_HEIGHT = UIScreen.main.bounds.height * 0.05
    /// like & watch cell always at index 0
    private static let LIKE_WATCH_CELL = 0

    private static let LIKE_WATACHED_CELL_LENGTH = 1
    private static let DESCRIPTON_CELL = 1

    
    private struct CommentCellStruct
    {
        var comment = String()
        var username = String()
        var image = String()
        var ext = String()
    }

    /// source is the total number of comments
    private var commentsSource = [CommentCellStruct]()

    private var mediaUID: String!
    private var mediaDetail: MediaDetail!
    
    private var headerView: UIView!
    private var updateHeaderlayout: CAShapeLayer!

    private let headerHeight: CGFloat = UIScreen.main.bounds.height * 0.6
    private let headerCut: CGFloat = 0
    private var cell0Info: LikeWatchedBookmarkCell!
    
    private var audioPlayer : AVAudioPlayer!
    private var isPlaying = false
    var isShowRecord = false
    

    @IBOutlet var videoPlayButton: UIButton!
    @IBOutlet var tableView: UITableView!

    @IBOutlet var displayPhotoImageView: UIImageView!

    @IBOutlet var cmmentText: UITextField!
    @IBOutlet var sendButton: UIButton!
    
    // MARK: - Methods
    
    override func viewDidLoad()
    {
        print("DisplayPhotoViewController : view did loaded ")
        super.viewDidLoad()

        self.hideKeyboardWhenTapped()

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tableView.rowHeight = UITableView.automaticDimension
        self.cmmentText.delegate = self
        self.sendButton.isUserInteractionEnabled = false
        
        self.setUpTableViewHeader()

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //self.setupVideoImageView()
        
    }
    
    public func setMediaDetailData(mediaDetail: MediaDetail)
    {
        self.mediaDetail = mediaDetail
        self.fillCommentSource()
        
    }

    public func fillCommentSource()
    {
        let currSrc: [MediaDetail.comment]? = self.mediaDetail.getComments()
        //ßprint("COMMENT SRC COUNT IS : ",currSrc!.count)
        //using DispatchGroup to wait for images to download:
        Util.ShowActivityIndicator(withStatus: "loading Comments...")
        let group = DispatchGroup()
        
        currSrc?.forEach{ item in
            group.enter()

                
            self.getPhotoFromDB(currentUserUID :item.username!.documentID , comment :item.message, group:group)

        }
        group.notify(queue: .main) {
            
            self.initialiseCommentSource()
            Util.DismissActivityIndicator()
        }
        
    }
    
    private func getPhotoFromDB(currentUserUID:String, comment : String?, group:DispatchGroup ){
            print("GET PHOTO FROM DB")
            DBController.getInstance().getDocumentFromCollection(collectionName: RegisterDBController.USER_COLLECTION_NAME, documentUID: currentUserUID) { (documentSnapshot, error) in
            if let error = error {
                print("error at fillCommentSource:::", error)
                 group.leave()
             //if we actually have photo, put it in to comment src now:
            }else if let imageUID = documentSnapshot!.get(RegisterDBController.USER_DOCUMENT_FIELD_PROFILE_PICTURE),
                let UIDExtension =  documentSnapshot!.get(RegisterDBController.USER_DOCUMENT_FIELD_PROFILE_PICTURE_EXTENSION) {
                print("ELSE IF RUNS")
                self.commentsSource
                                           .append(
                                               DisplayPhotoViewController
                                                   .CommentCellStruct(
                                                 comment: comment ?? "",
                                                 username: documentSnapshot!.get(RegisterDBController.USER_DOCUMENT_FIELD_NAME) as! String,
                                                 image :imageUID as! String,
                                                 ext :UIDExtension as! String
                                             ))
                group.leave()
            //if we dont have photo, we need to set a default image:
            } else{
                print(" ELSE RUNS")
                self.commentsSource
                  .append(
                      DisplayPhotoViewController
                          .CommentCellStruct(
                        comment: comment ?? "",
                        username: documentSnapshot!.get(RegisterDBController.USER_DOCUMENT_FIELD_NAME) as! String,
                        image :ImageAsset.default_image.rawValue,
                        ext :Util.EXTENSION_JPEG
                    ))
                group.leave()
                }
    
            }
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
            sendButton.setImage(ImageAsset.disable_send_icon.image, for: .normal)
         sendButton.isEnabled = false
        } else {
            sendButton.isUserInteractionEnabled = true
         sendButton.isEnabled = true
            sendButton.setImage(ImageAsset.able_send_icon.image, for: .normal)
        }
         return true
    }

    /// Send comment Action
    /// - Parameter sender: the send button
    @IBAction func EnterComment(_: Any)
    {
        self.cmmentText.endEditing(true)

        let username = Auth.auth().currentUser!.uid
        if self.cmmentText.text!.count != 0 {
            self.storeCommentToServer(username: DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.USER_COLLECTION_NAME, documentUID: username), comment: self.cmmentText.text!, photoUID: self.mediaDetail.getUID())
            self.cmmentText.text = ""
        }
        // disable the button after sending the comment
        sendButton.setImage(ImageAsset.disable_send_icon.image, for: .normal)
        sendButton.isUserInteractionEnabled = false
    
    }
    
    private func initialiseCommentSource()
         {
             // pull new comment from the server
            if commentsSource.count == 0{
                return 
            }
             var indexPaths = [IndexPath]()
             
             
             //print("num of row before update: ",self.tableView.numberOfRows(inSection: 0))
             self.tableView.beginUpdates()
             var ctr :Int = 0
             self.commentsSource.forEach { (item) in
                 indexPaths.append(IndexPath(row: ctr+2, section: 0))

                 self.tableView.insertRows(at: indexPaths, with: .top)
                 ctr += 1
             }
             

             //        print("COUNT IS: " ,commentsSource.count)
             
             
             self.tableView.endUpdates()
             self.tableView.scrollToRow(at: IndexPath(row: self.commentsSource.count+1, section: 0), at: .bottom, animated: true)

         }

    private func updateCommentSource()
    {
        // pull new comment from the server
        
        var indexPaths = [IndexPath]()
        print("commentsrc ctr at before updateCommentSource : ", self.commentsSource.count)
        
        let updateAtRow = self.commentsSource.count + 1
        print("num of row before update: ",self.tableView.numberOfRows(inSection: 0))
        self.tableView.beginUpdates()
        

        indexPaths.append(IndexPath(row: updateAtRow, section: 0))

        self.tableView.insertRows(at: indexPaths, with: .top)
        
        self.tableView.endUpdates()
        self.tableView.scrollToRow(at: IndexPath(row: updateAtRow, section: 0), at: .bottom, animated: true)

    }

    private func storeCommentToServer(username: DocumentReference, comment: String, photoUID: String)
    {
        AlbumDBController.getInstance().UpdateComments(username: username, comment: comment, commentedPhotoUID: photoUID)

        let group = DispatchGroup()
        group.enter()
        Util.ShowActivityIndicator()
        self.getPhotoFromDB(currentUserUID: username.documentID, comment: comment, group:group)

        group.notify(queue: .main)
        {
            
            self.updateCommentSource()
            Util.DismissActivityIndicator()
        }
       
    }
    
   

    @objc func imageTapped(_ sender: UITapGestureRecognizer)
    {
        print("TEST IF I TAP ::")
        // show photo:
        if mediaDetail.ext.contains(Util.EXTENSION_JPEG)  ||
            mediaDetail.ext.contains(Util.EXTENSION_PNG){
            
            let imageView = sender.view as! UIImageView
                  let controller = storyboard!.instantiateViewController(withIdentifier: "ShowDetailPhotoViewController") as! ShowDetailPhotoViewController
                  controller.selectedImage = imageView.image
                  present(controller, animated: true)
            // else, play video:
        } else if mediaDetail.ext.contains(Util.EXTENSION_M4V) ||
            mediaDetail.ext.contains(Util.EXTENSION_MP4) ||
            mediaDetail.ext.contains(Util.EXTENSION_MOV){
            
            self.videoPlay()
        }
      
    }

    @objc func scrollBackToTop(sender: UILongPressGestureRecognizer)
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
    
    private func videoPlay(){
        let controller = AVPlayerViewController()
        print("IMAGE TAPPED IM RUNNING")
        Util.GetLocalFileURL(by: mediaDetail.UID, type: .video){
            url in
            print("GET LOCAL URL",   URL(fileURLWithPath: url!.absoluteString) )
            
            DispatchQueue.main.async {
                
                controller.player = AVPlayer(url:  URL(fileURLWithPath: url!.absoluteString))
                self.present(controller, animated: true, completion: nil)
            }
        }
    }

    // MARK: - Table view data source

    //
    func numberOfSections(in _: UITableView) -> Int
    {
        // return the number of sections
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int
    {
        print("numberOfRowsInSection : how often do you called ?")
        // return the number of rows
        return  DisplayPhotoViewController.LIKE_WATACHED_CELL_LENGTH +
            DisplayPhotoViewController.DESCRIPTON_CELL + self.commentsSource.count
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

    /// the row only get call when it's visible on the screeen in order to save memory
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


            cell0.selectionStyle = UITableViewCell.SelectionStyle.none

            // load the likeNumbers and watched numbers
            cell0.likeNumbers.text = String(self.mediaDetail.getLikesCounter())
            
            //check if you have watched it before?
            self.mediaDetail.hasWatch()

            cell0.watchedNumbers.text = String(self.mediaDetail.getWatch())

            return cell0
        }
        else if (indexPath.row == 1) {

            let descriptionCell = self.tableView.dequeueReusableCell(withIdentifier: DisplayPhotoViewController.descriptionTableViewCell, for: indexPath) as! DescriptionCell
            print("the description : " + mediaDetail.getDescription())
            descriptionCell.setDescriptionLabel(description: mediaDetail.getDescription())
            print("you don't call this, do you? : " + mediaDetail.audioUID)
            descriptionCell.setAudioUID(audioUID: mediaDetail.audioUID)
            
            if self.mediaDetail.audioUID.removingWhitespaces().isEmpty{
                descriptionCell.playAudioButton.isHidden = true
            }
            else {
                Util.GetLocalFileURL(by: self.mediaDetail.audioUID, type: .audio, error: {
                    e in
                    if let _ = e {
                          descriptionCell.playAudioButton.isHidden = true
                    }
              
                })
            }
            descriptionCell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            return descriptionCell

        }
        else {
            // create comment cell
            // show the comments, if there are hidden cells, show expandsion cell in the last cell
            print("creating comment cell ::: ")

            let cell1 = tableView.dequeueReusableCell(withIdentifier: DisplayPhotoViewController.commentTableViewCell, for: indexPath) as! CommentCell
            cell1.setUsernameLabel(username: self.commentsSource[indexPath.row - 2].username)
            cell1.setCommentLabel(comment: self.commentsSource[indexPath.row - 2].comment)
            Util.GetImageData(imageUID: self.commentsSource[indexPath.row - 2].image, UIDExtension: self.commentsSource[indexPath.row - 2].ext, completion: {
            data in
                let width = cell1.userProfileImage.bounds.width
                let height = cell1.userProfileImage.bounds.height
                Util.UserInitThread(work: {
                    // resize image in worker thread
                    let image = RBResizer.RBResizeImage(image: UIImage(data:data!), targetSize: CGSize(width: width, height: height))
                    DispatchQueue.main.async {
                        cell1.userProfileImage.image = image
                    }
                })
                                          
            })
            
            cell1.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell1
        }
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == 0 {
            return DisplayPhotoViewController.LIKES_ROW_HEIGHT
        } else if indexPath.row == 1 {
            return UITableView.automaticDimension
        }
        else {
            return UITableView.automaticDimension
        }
    }

    /// the header that shows to image
    private func setUpTableViewHeader()
    {
        // test on read file for local file
        Util.GetImageData(imageUID: self.mediaDetail.getUID(), UIDExtension: Util.EXTENSION_JPEG, completion: {
            data in
            self.displayPhotoImageView.image = UIImage(data: data!)
        })
        self.headerView = self.tableView.tableHeaderView
        self.updateHeaderlayout = CAShapeLayer()

        self.tableView.UpdateView(headerView: self.headerView, updateHeaderlayout: self.updateHeaderlayout, headerHeight: self.headerHeight, headerCut: self.headerCut)

        let headerViewGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.scrollBackToTop))
        
        let zoomInGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
        //zoomInGesture.numberOfTapsRequired = 2

        // note: GestureRecognizer will be disable while tableview is scrolling
        self.headerView.addGestureRecognizer(headerViewGesture)
        self.displayPhotoImageView.addGestureRecognizer(zoomInGesture)
         if mediaDetail.ext.contains(Util.EXTENSION_JPEG)  ||
                          mediaDetail.ext.contains(Util.EXTENSION_PNG){
                  
                   videoPlayButton.isHidden = true
    
                          // else, play video:
              } else if mediaDetail.ext.contains(Util.EXTENSION_M4V) ||
                  mediaDetail.ext.contains(Util.EXTENSION_MP4) ||
                  mediaDetail.ext.contains(Util.EXTENSION_MOV){
                
                    
                    self.videoPlayButton.isHidden = false
              
              
               }
        
    
    }
    
    @IBAction func videoTap(_ sender: Any) {
        self.videoPlay()
    }
    
    /// Override to support conditional editing of the table view.
    func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool
    {
        // Return false if you do not want the specified item to be editable.
        return true
    }

}
