//
//  SideMenuTableViewController.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/11.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit
import SideMenu
import Firebase

class SideMenuTableViewController: UITableViewController {
    
    private static let SHOW_PROFILE_VIEW_SEGUE = "ShowProfileViewController"
    
    enum Gender : String{
        case Male
        case Female
    }
    
    struct UserInfo {
        var username: String
        var imageUID: String?
        var imageExtension: String?
        var phone: String?
        var gender: Gender?
        var familyRelation: String?
    }
    
    var userInformation: UserInfo!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear: do you get called")
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        // refresh cell blur effect in case it changed
        tableView.reloadData()
        
        guard let menu = navigationController as? UISideMenuNavigationController, menu.blurEffectStyle == nil else {
            return
        }
        
        // Set up a cool background image for demo purposes
//        let imageView = UIImageView(image: #imageLiteral(resourceName: "saturn"))
//        imageView.contentMode = .scaleAspectFit
//        imageView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
//        tableView.backgroundView = imageView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         super.viewWillAppear(animated)
         self.navigationController?.setNavigationBarHidden(false, animated: true)
         print("viewWillDisappear: do you get called")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! UITableViewVibrantCell
        
        // add profile
        if indexPath.row == 0 {
            
            let cellImg: UIImageView!
            cellImg = UIImageView(frame: CGRect(x: 15, y: 10, width: 80, height: 80))
            cellImg.layer.cornerRadius = 40
            cellImg.layer.masksToBounds=true
            cellImg.contentMode = .scaleAspectFill
            cellImg.layer.masksToBounds=true
            
            if let imageUID = userInformation.imageUID,
                let imageExtension = userInformation.imageExtension {
                print("tableView : user has profile info with ID " + imageUID)
                print("tableView : user has profile info with Extension " + imageExtension)
                Util.GetImageData(imageUID: imageUID,
                                  UIDExtension: imageExtension, completion: {
                    data in
                    cellImg.image = data != nil ? UIImage(data: data!): #imageLiteral(resourceName: "item4")
                })
                
            }else{
                print("tableView : user has no profile info ")
                cellImg.image = #imageLiteral(resourceName: "item4")
            }
            
            cell.addSubview(cellImg)
            
            let cellLbl = UILabel(frame: CGRect(x: 110, y: cell.frame.height/2-15, width: 250, height: 30))
            cell.addSubview(cellLbl)
            cellLbl.text = userInformation.username
            cellLbl.font = UIFont.systemFont(ofSize: 17)
            cellLbl.textColor = UIColor.black
        }
        
        if let menu = navigationController as? UISideMenuNavigationController {
            cell.blurEffectStyle = menu.blurEffectStyle
        }
        

        return cell
    }
    
    // The sign out table view function
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.row == 4)
        {
            let alertController = UIAlertController(title: "Log out", message:"Are you sure to log out?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "NO", style: .default))
            alertController.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action: UIAlertAction!) in
                do {
                    // dismiss the side bar(have to)
                    self.dismiss(animated: true, completion: nil)
                    try Auth.auth().signOut()
                    CacheHandler.getInstance().cleanCache()
                    
                }catch let e as NSError {
                    print("you get error")
                    Util.ShowAlert(title: "Sign Out Fail", message: e.localizedDescription, action_title: Util.BUTTON_DISMISS, on: self)
                }

            }))
            self.present(alertController, animated: true, completion: nil)
            
        }else if(indexPath.row == 0 || indexPath.row == 2){
            self.performSegue(withIdentifier: SideMenuTableViewController.SHOW_PROFILE_VIEW_SEGUE, sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SideMenuTableViewController.SHOW_PROFILE_VIEW_SEGUE {
            if let profileVC = segue.destination as? ProfileViewController {
                // todo : pass cache here !!!!
                print(" SideMenuTableViewController prepare : pass success !");
                profileVC.userInformation = self.userInformation
            }
        }
    }
}
