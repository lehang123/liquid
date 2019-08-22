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
    
    struct userInfo {
        var username: String
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
            cellImg.image=#imageLiteral(resourceName: "tempProfileImage")
            cell.addSubview(cellImg)
            
            let cellLbl = UILabel(frame: CGRect(x: 110, y: cell.frame.height/2-15, width: 250, height: 30))
            cell.addSubview(cellLbl)
            cellLbl.text = "HELLO PSYDUCK"
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
                    
                    
                }catch let e as NSError {
                    print("you get error")
                    Util.ShowAlert(title: "Sign Out Fail", message: e.localizedDescription, action_title: Util.BUTTON_DISMISS, on: self)
                }

            }))
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    

}
