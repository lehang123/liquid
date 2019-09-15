//
//  DisplayPhotoViewController.swift
//  ITProject
//
//  Created by Gong Lehan on 22/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit

// todo : make the scorll back to the top while click on the header
class DisplayPhotoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    private static let likeWatchedBookmarkTableViewCell = "LikeWatchedBookmarkCell"
    private static let commentTableViewCell = "CommentCell"
    private static let expandCollpaseTableViewCell = "ExpandCell"
    
    private static let HEADER_MIN_HEIGHT = UIScreen.main.bounds.height * 0.4
    private static let LIKES_ROW_HEIGHT = UIScreen.main.bounds.height * 0.05
    private static let COMMENT_ROW_HEIGHT = UIScreen.main.bounds.height * 0.05
    private static let EXPAND_ROW_HEIGHT = UIScreen.main.bounds.height * 0.025
    private static let MAXIMUM_INIT_LIST_LENGTH = 10
    private static let MAXIMUM_EXPAND_LENGTH = 5
    
    
    private struct CommentCellStruct{
        var comment = String()
        var username = String()
    }
    private var commentsSource = [CommentCellStruct]()
    private var commentCellsList = [CommentCellStruct]()
    private var hasHiddenCells = false
    
    private var photoUID: String!
    
    public func setPhotoUID(photoUID: String){
        self.photoUID = photoUID
    }
    
    private var headerView : UIView!
    private var updateHeaderlayout : CAShapeLayer!
    
    private let headerHeight : CGFloat = UIScreen.main.bounds.height * 0.6
    private let headerCut : CGFloat = 0
    
    private var tableView_cell_length = 0
    
    @IBOutlet weak var displayPhotoImageView: UIImageView!
 
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        print("DisplayPhotoViewController : view did loaded ")
        super.viewDidLoad()
        
        makeDummyCommentSource(num: 20)

        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        initCommentCellsList()
        setUpTableViewHeader()
        
        // first one (1 +) for like, watched cell + list length (but when the list is too long, we are going to hide it and expand view appear)
        
        //current cell doesn't show all the comments
        if (commentsSource.count > commentCellsList.count){
            print("there is more source")
            hasHiddenCells = true
        }
    }
    
    
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "ShowDetailPhotoViewController") as! ShowDetailPhotoViewController
        controller.selectedImage = imageView.image
        self.present(controller, animated: true)
    }

    
    @objc func scrollBackToTop(sender : UITapGestureRecognizer) {
        // make sure sender is not nil
        guard sender.view != nil else { return }
        if sender.state == .ended {// when touches end, scroll to top
            let topIndex = IndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at: topIndex, at: .top , animated: true)
        }
    }
    

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.tableView.Setupnewview(headerView: headerView, updateHeaderlayout: updateHeaderlayout, headerHeight: headerHeight, headerCut: headerCut, headerStopAt: CGFloat(DisplayPhotoViewController.HEADER_MIN_HEIGHT))
    }

    // MARK: - Table view data source
    // todo: only one for now, afterward, there is a way to expand a comment
    func numberOfSections(in tableView: UITableView) -> Int {
        // return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        if hasHiddenCells{
            return tableView_cell_length + 1
        }else{
            return tableView_cell_length
        }
    }

    /*the row only get call when it's visible on the screeen in order to save memory*/
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {// like, watched cell. always there
            let cell0 = tableView.dequeueReusableCell(withIdentifier: DisplayPhotoViewController.likeWatchedBookmarkTableViewCell, for: indexPath) as! LikeWatchedBookmarkCell
            return cell0
        }else {// create comment cell
            // show the comments, if there are hidden cells, show expandsion cell in the last cell
            if !hasHiddenCells || tableView_cell_length != indexPath.row{
                
                print("cellForRowAt : " + String(hasHiddenCells) + " and " + String(indexPath.row))
                
                let cell1 = tableView.dequeueReusableCell(withIdentifier: DisplayPhotoViewController.commentTableViewCell, for: indexPath) as!CommentCell
                cell1.setUsernameLabel(username: commentCellsList[indexPath.row - 1].username)
                cell1.setCommentLabel(comment: commentCellsList[indexPath.row - 1].comment)
                return cell1
            }else {
                let cell1 = tableView.dequeueReusableCell(withIdentifier: DisplayPhotoViewController.expandCollpaseTableViewCell, for: indexPath) as!ExpandCell
                return cell1
            }
        }
    }
    /* when row is selected, row expand test done.
     todo :
            1.change the selected animation effect to touched
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (tableView.cellForRow(at: indexPath)?.isKind(of: ExpandCell.self))!{
            let selectedCell =
                tableView.cellForRow(at: indexPath)as! ExpandCell
            
            if selectedCell.cellState == ExpandCell.Work.Expand{
                // start expand here, expand at most 5 at a time, until source end
                expandTableView(selectedCell: selectedCell)
            }else if selectedCell.cellState == ExpandCell.Work.Collapse{
                // start collapse here, collapse all the way back to max_init_cells
                collapseTableView(selectedCell: selectedCell, tableView: tableView )
            }
        }
    }
    
    private func collapseTableView(selectedCell: ExpandCell, tableView: UITableView){
        let numOfRow = tableView.numberOfRows(inSection: 0)
        var indexPaths = [IndexPath]()
        let start = DisplayPhotoViewController.MAXIMUM_INIT_LIST_LENGTH+1
        let end  = numOfRow-2
        var a = 0
        
        for i in start...end{
            a+=1
            print("removing : " + String(i))
            let indexPath = IndexPath(row: i, section: 0)
            indexPaths.append(indexPath)
        }
        
        removeLastCommentCellsFromList(numOfCells: end-start+1)
        
        tableView.beginUpdates()
        tableView.deleteRows(at: indexPaths, with: .automatic)
        tableView.endUpdates()
        
        selectedCell.setLogoExpand()
    }
    
    private func expandTableView(selectedCell: ExpandCell){
        var indexPaths = [IndexPath]()
        for _ in 1...DisplayPhotoViewController.MAXIMUM_EXPAND_LENGTH{
            if commentsSource.count<=(commentCellsList.count){
                print("no more source")
                selectedCell.setLogoCollapse()
                break
            }
            print("didSelectRowAt : " + "at " + String((commentCellsList.count)))
            addCommentCellToList( commentStruct: commentsSource[(commentCellsList.count)])
            let indexPath = IndexPath(row: tableView_cell_length-1, section: 0)
            indexPaths.append(indexPath)
        }
        
        tableView.beginUpdates()
        tableView.insertRows(at: indexPaths, with: .automatic)
        tableView.endUpdates()
        
        if commentsSource.count<=(commentCellsList.count){
            print("no more source")
            selectedCell.setLogoCollapse()
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.row == 0 {
            return DisplayPhotoViewController.LIKES_ROW_HEIGHT
        }else if indexPath.row == tableView_cell_length && hasHiddenCells{
            return DisplayPhotoViewController.EXPAND_ROW_HEIGHT
        }else {
            return UITableView.automaticDimension
        }
        //should never go here
    }
    
    private func makeDummyCommentSource(num: Int){

        for i in 1...num {
            var commentCell = CommentCellStruct()
            commentCell.comment = "mkk" + String(i)
            commentCell.username = "username" + String(i)
            commentsSource.append(commentCell)
        }
    }
    
    /* the header that shows to image */
    private func setUpTableViewHeader(){
        /*test on read file for local file*/
        Util.GetImageData(imageUID: photoUID, UIDExtension: Util.EXTENSION_JPEG, completion: {
                data in
            self.displayPhotoImageView.image = UIImage(data: data!)
        })
        headerView = tableView.tableHeaderView
        updateHeaderlayout = CAShapeLayer()

        self.tableView.UpdateView(headerView: headerView, updateHeaderlayout: updateHeaderlayout, headerHeight: headerHeight, headerCut: headerCut)
        
        let headerViewGesture = UITapGestureRecognizer(target: self, action:  #selector(self.scrollBackToTop))
        /* note: GestureRecognizer will be disable while tableview is scrolling */
        headerView.addGestureRecognizer(headerViewGesture)
    }
    
    private func initCommentCellsList(){
        // load at most 5 comments from caches
        if (commentsSource.count != 0) {
            for i in 1...min(DisplayPhotoViewController.MAXIMUM_INIT_LIST_LENGTH, commentsSource.count) {
                addCommentCellToList( commentStruct: commentsSource[i-1])
            }
        }
    }
    
    private func addCommentCellToList(commentStruct: CommentCellStruct){
        commentCellsList.append(commentStruct)
        tableView_cell_length = 1 + commentCellsList.count
    }
    
    private func addCommentCellToList(username: String, comment: String){
        var commentCell = CommentCellStruct()
        commentCell.comment = comment
        commentCell.username = username
        commentCellsList.append(commentCell)
        tableView_cell_length = 1 + commentCellsList.count
    }
    
    private func removeLastCommentCellsFromList(numOfCells : Int){
        commentCellsList.removeLast(numOfCells)
        tableView_cell_length = tableView_cell_length - numOfCells
    }

    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
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
