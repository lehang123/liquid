//
//  DisplayPhotoViewController.swift
//  ITProject
//
//  Created by Gong Lehan on 22/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit

// todo : make the scorll back to the top while click on the header
class DisplayPhotoViewController: UITableViewController {
    private static let displayPhotoTableViewCell = "displayPhotoTableViewCell"
    private static let HEADER_MIN_HEIGHT = UIScreen.main.bounds.height * 0.4
    
    var headerView : UIView!
    var updateHeaderlayout : CAShapeLayer!
    
    private let headerHeight : CGFloat = UIScreen.main.bounds.height * 0.6
    private let headerCut : CGFloat = 0
    
    @IBOutlet weak var displayPhotoImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        displayPhotoImageView.image = #imageLiteral(resourceName: "item4")
        headerView = tableView.tableHeaderView
        updateHeaderlayout = CAShapeLayer()
        self.UpdateView(headerView: headerView, updateHeaderlayout: updateHeaderlayout, headerHeight: headerHeight, headerCut: headerCut)
        let headerViewGesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        /* note: GestureRecognizer will be disable while tableview is scrolling */
        headerView.addGestureRecognizer(headerViewGesture)
        
    }
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
        // make sure sender is not nil
        guard sender.view != nil else { return }
        if sender.state == .ended {// when touches end, scroll to top
            let topIndex = IndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at: topIndex, at: .top , animated: true)
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.Setupnewview(headerView: headerView, updateHeaderlayout: updateHeaderlayout, headerHeight: headerHeight, headerCut: headerCut, headerStopAt: CGFloat(DisplayPhotoViewController.HEADER_MIN_HEIGHT))
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 20
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell0 = tableView.dequeueReusableCell(withIdentifier: DisplayPhotoViewController.displayPhotoTableViewCell, for: indexPath) as! DisplayPhotoTableViewCell
            cell0.displayImage = #imageLiteral(resourceName: "tempFamilyImage")
            return cell0
        } else {
            let cell0 = tableView.dequeueReusableCell(withIdentifier: DisplayPhotoViewController.displayPhotoTableViewCell, for: indexPath) as! DisplayPhotoTableViewCell
            cell0.displayImage = #imageLiteral(resourceName: "tempFamilyImage")
            return cell0
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(100)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
