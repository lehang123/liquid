//
//  SideMenuTableViewController.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/11.
//  Copyright © 2019 liquid. All rights reserved.
//

import Firebase
import SideMenu
import UIKit

/// User information detail structure
struct UserInfo
{
	var username: String
	var imageUID: String?
	var imageExtension: String?
	var gender: String?
	var dateOfBirth: Date?
	var familyRelation: String?
	var userInfoDelegate: UserProfileViewDelegate!
}

/// The gender's possible values (DEPRECATED)
enum Gender: String
{
	case Male
	case Female
	case Unknown
}

/// User family information detail structure
struct UserFamilyInfo
{
	var familyUID: String!
	var familyName: String?
	var familyProfileUID: String?
	var familyProfileExtension: String?
	var familyMottoText: String?
	var familyInfoDelegate: FamilyProfileViewDelegate!
}

///  Side Menu UI's View Controller.
class SideMenuTableViewController: UITableViewController {
    // MARK: - Constants and Properties
    private static let SHOW_PROFILE_VIEW_SEGUE = "ShowProfileViewController"
    private static let SHOW_FAMILY_PROFILE_VIEW_SEGUE = "ShowFamilyProfileViewController"
    private static let SHOW_FAMILY_TABLE_VIEW_SEGUE = "ShowFamilyTableViewController"
    
    private static let PERSONAL_PROFILE_CELL = 0
    private static let PERSONAL_SETTING_CELL = 2
    private static let FAMILY_SETTING_CELL = 1
    private static let FAMILY_TREE_CELL = 3

    var userInformation: UserInfo!
    var userFamilyInformation: UserFamilyInfo!

    // MARK: - Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear: do you get called")
        navigationController?.setNavigationBarHidden(true, animated: true)
        // refresh cell blur effect in case it changed
        tableView.reloadData()

        guard let menu = navigationController as? UISideMenuNavigationController, menu.blurEffectStyle == nil else {
            return
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        print("viewWillDisappear: do you get called")
    }

    /// setup a table view for Side Menu.
    /// - Parameters:
    ///   - tableView: A table-view object requesting the cell.
    ///   - indexPath: An index path locating a row in tableView.
    /// - Returns: An object inheriting from UITableViewCell that the table view can use for the specified row.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! UITableViewVibrantCell

        // add profile
        if indexPath.row == 0 {
            let cellImg: UIImageView!
            cellImg = UIImageView(frame: CGRect(x: 15, y: 10, width: 80, height: 80))
            cellImg.layer.cornerRadius = 40
            cellImg.layer.masksToBounds = true
            cellImg.contentMode = .scaleAspectFill
//            cellImg.layer.masksToBounds=true

            if let imageUID = userInformation.imageUID,
                let imageExtension = userInformation.imageExtension {
                print("tableView : user has profile info with ID " + imageUID)
                print("tableView : user has profile info with Extension " + imageExtension)
                Util.GetImageData(imageUID: imageUID,
                                  UIDExtension: imageExtension, completion: {
                                      data in
                                      cellImg.image = data != nil ? UIImage(data: data!) : #imageLiteral(resourceName: "item4")
                })

            } else {
                print("tableView : user has no profile info ")
                cellImg.image = #imageLiteral(resourceName: "item4")
            }

            cell.addSubview(cellImg)

            let cellLbl = UILabel(frame: CGRect(x: 110, y: cell.frame.height / 2 - 15, width: 250, height: 30))
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
    /// - Parameters:
    ///   - tableView: A table-view object requesting the cell.
    ///   - indexPath: An index path locating a row in tableView.
    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 4 {
            let alertController = UIAlertController(title: "Log out", message: "Are you sure to log out?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "NO", style: .default))
            alertController.addAction(UIAlertAction(title: "YES", style: .default, handler: { (_: UIAlertAction!) in

                // dismiss the side bar(have to)
                self.dismiss(animated: true, completion: {
                    do {
                        try Auth.auth().signOut()
                    } catch let e as NSError {
                        print("you get error")
                        Util.ShowAlert(title: "Sign Out Fail", message: e.localizedDescription, action_title: Util.BUTTON_DISMISS, on: self)
                    }

                })
            }))

            present(alertController, animated: true, completion: nil)

        } else if indexPath.row == 0 || indexPath.row == 2 {
            performSegue(withIdentifier: SideMenuTableViewController.SHOW_PROFILE_VIEW_SEGUE, sender: self)
        } else if indexPath.row == 1 {
            performSegue(withIdentifier: SideMenuTableViewController.SHOW_FAMILY_PROFILE_VIEW_SEGUE, sender: self)
        } else if indexPath.row == 3 {
            performSegue(withIdentifier: SideMenuTableViewController.SHOW_FAMILY_TABLE_VIEW_SEGUE, sender: self)
        }
    }
    
    /// prepare for next view : showing profile / family profile.
    /// - Parameters:
    ///   - segue: the link to the next vc
    ///   - sender: sender
    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == SideMenuTableViewController.SHOW_PROFILE_VIEW_SEGUE {
            if let profileVC = segue.destination as? ProfileViewController {
                print(" SideMenuTableViewController prepare : pass success !")
                profileVC.userInformation = userInformation
            }
        } else if segue.identifier == SideMenuTableViewController.SHOW_FAMILY_PROFILE_VIEW_SEGUE {
            if let FamilyProfileVC = segue.destination as? FamilyProfileViewController {
                print(" SideMenuTableViewController prepare : pass success !")
                FamilyProfileVC.userFamilyInfo = userFamilyInformation
            }
        } else if segue.identifier == SideMenuTableViewController.SHOW_FAMILY_TABLE_VIEW_SEGUE {
            if let FamilyTableVC = segue.destination as? FamilyTableViewController {
                print(" SideMenuTableViewController prepare : pass success !")
                FamilyTableVC.userFamilyInfo = userFamilyInformation
            }
        }
    }
}
