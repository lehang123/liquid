//
//  FamilyMainPageViewController.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/8.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit

import EnhancedCircleImageView
import Firebase
import FirebaseStorage
import SideMenu
import UPCarouselFlowLayout
import CoreLocation

// MARK: - Structor
struct ModelCollectionFlowLayout
{
	var title: String = ""
	var image: UIImage!
}

// MARK: - Delegation
protocol FamilyProfileViewDelegate
{
	func didUpdateFamilyInfo()
}

protocol UserProfileViewDelegate
{
	func didUpdateUserInfo()
}


class FamilyMainPageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, FamilyProfileViewDelegate, UserProfileViewDelegate
{
	// MARK: - Constants and Properties
	private static let SHOW_ALBUM_COVERS_VIEW = "ShowAlbumCovers"
	private static let SHOW_SIDE_MENU_VIEW = "ShowSideMenuBar"
    private static let SHOW_TIMELINE_VIEW = "ShowTimeline"
    private static let SHOW_FAMILY_SETTING_VIEW = "ShowFamilyProfileSettingVC"
    private static let SHOW_PROFILE_VIEW_SEGUE = "ShowProfileViewController"
    
	private var familyUID: String!
    private var name: String?
	private var familyProfileUID: String?
	private var familyProfileExtension: String?
	private var familyPosition: String?
	private var DOB : Date?
    private var gender : String?

	private var profileURL: String?
	private var profileExtension: String?
    
    @IBOutlet weak var familyName: UILabel!
    
	@IBOutlet var familyMotto: UILabel!
	@IBOutlet var familyProfileImg: EnhancedCircleImageView!
	@IBOutlet var profileImgContainer: UIView!
	@IBOutlet var carouselCollectionView: UICollectionView!

	var items = [ModelCollectionFlowLayout]()
    
    // MARK: - Methods
	override func viewDidLoad()
	{
		super.viewDidLoad()
		print("view did loaded called")
		self.login()

		navigationController?.navigationBar.items?.forEach
		{
			item in
			item.leftBarButtonItem?.tintColor = UIColor.black
		}

		// set Profile Image
		// loading profileImage with shadow
		self.familyProfileImg.layer.shadowColor = UIColor.selfcGrey.cgColor
		self.familyProfileImg.layer.shadowOpacity = 0.7
		self.familyProfileImg.layer.shadowOffset = CGSize(width: 10, height: 10)
		self.familyProfileImg.layer.shadowRadius = 1
		self.familyProfileImg.clipsToBounds = false

		// carousel effect
		self.setupCarouselEffect()
	}

	/// In a storyboard-based application, you will often want to do a little preparation before navigation
	///
	/// - Parameters:
	///   - segue: the next vc
	///   - sender: sender
	override func prepare(for segue: UIStoryboardSegue, sender _: Any?)
	{
		// Get the new view controller using segue.destination.
		// Pass the selected object to the new view controller.
		if segue.identifier == FamilyMainPageViewController.SHOW_ALBUM_COVERS_VIEW
		{
			if let albumDetailTVC = segue.destination as? AlbumCoverViewController
			{
				// todo : pass cache here !!!!
				print(" FamilyMainPageViewController prepare : pass success !")
				self.passAlbumsData(to: albumDetailTVC)
			}
		}
		else if segue.identifier == FamilyMainPageViewController.SHOW_SIDE_MENU_VIEW
		{
			if let sideMenuNC = segue.destination as? UISideMenuNavigationController
			{
				if let sideMenuVC = sideMenuNC.visibleViewController as? SideMenuTableViewController
				{
					print(" FamilyMainPageViewController prepare : UISideMenuNavigationController !")

					// pass user info to the current sideMenuVC
                    
                   
					sideMenuVC.userInformation = getUserInformation()
                    

					// pass user's family info to the current sideMenuVC
					sideMenuVC.userFamilyInformation = UserFamilyInfo(
						familyUID: self.familyUID,
                        familyName: self.familyName.text,
						familyProfileUID: self.familyProfileUID,
						familyProfileExtension: self.familyProfileExtension,
						familyMottoText: self.familyMotto.text,
						familyInfoDelegate: self
					)
				}
			}
		}
        else if segue.identifier == FamilyMainPageViewController.SHOW_TIMELINE_VIEW
        {
            print("PREPARING FOR TIMELINE BRO")
            if let timelineVC = segue.destination as? TimelineViewController
            {
                // todo : pass cache here !!!!
                print(" SHOW_TIMELINE_VIEW prepare : pass success !")
                timelineVC.familyUID = self.familyUID
                
            }
        }
        else if segue.identifier == FamilyMainPageViewController.SHOW_FAMILY_SETTING_VIEW
        {
            if let fpVC = segue.destination as? FamilyProfileViewController
            {
                // todo : pass cache here !!!!
                print(" SHOW_TIMELINE_VIEW prepare : pass success !")
                
                // pass user's family info to the current sideMenuVC
                fpVC.userFamilyInfo = UserFamilyInfo(
                    familyUID: self.familyUID,
                    familyName: self.familyName.text,
                    familyProfileUID: self.familyProfileUID,
                    familyProfileExtension: self.familyProfileExtension,
                    familyMottoText: self.familyMotto.text,
                    familyInfoDelegate: self
                )
                
            }
            
        }
	}
    
    /// Set up carousel effect
    private func setupCarouselEffect(){
        self.collectData()
        self.carouselCollectionView.showsHorizontalScrollIndicator = false
        self.carouselCollectionView.register(UINib(nibName: "CarouselEffectCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")

        let flowLayout = UPCarouselFlowLayout()

        flowLayout.itemSize = CGSize(width: 320 / 2.5, height: 187.5)
        print("height ::: ", self.carouselCollectionView.frame.size.height)
        flowLayout.scrollDirection = .horizontal
        flowLayout.sideItemScale = 0.8
        flowLayout.sideItemAlpha = 1.0
        flowLayout.spacingMode = .fixed(spacing: 5.0)
        self.carouselCollectionView.collectionViewLayout = flowLayout
    }
    
    func getUserInformation() -> UserInfo{
        return  UserInfo(
                            username: self.name ?? "Not Available",
                            imageUID: self.profileURL ?? ImageAsset.default_image.rawValue,
                            imageExtension: self.profileExtension ?? Util.EXTENSION_JPEG,
                            gender: self.gender ?? "Not Available",
                            dateOfBirth: self.DOB,
                            familyRelation: self.familyPosition ?? "Not Available",
                            userInfoDelegate: self
                        )
    }
    
	func didUpdateFamilyInfo()
	{
		// reload Family Info
		if Auth.auth().currentUser != nil
		{
			self.loadFamilyInfoFromServer()
		}
	}

	func didUpdateUserInfo()
	{
		// reload User Info
		if Auth.auth().currentUser != nil
		{
			self.loadUserInfoFromServer()
		}
	}

	private func passAlbumsData(to albumDetailTVC: AlbumCoverViewController)
	{
		// start pulling data from server : albums info
		AlbumDBController.getInstance().getAlbumInfo(familyID: DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.FAMILY_COLLECTION_NAME, documentUID: self.familyUID), completion: {
			albumDic, error in
			if let err = error
			{
				print("error occurs during passAlbumsData : " + err.localizedDescription)
			}
			else
			{
				albumDic.forEach
				{
					data in

					let (albumName, albumDetails) = data
                    let dateTimestamp = albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_CREATED_DATE]
                    
                 //   print("audioID IS : ",  albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_AUDIO] ?? "empty")
           
					albumDetailTVC.loadAlbumToList(title: albumName,
					                               description: albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_DESCRIPTION] as! String,
					                               UID: albumDetails[AlbumDBController.DOCUMENTID] as! String,
					                               coverImageUID: albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL] as? String,
					                               coverImageExtension: albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL_EXTENSION] as? String,
                                                   location: albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_LOCATION] as? String ?? "", audioID: albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_AUDIO] as? String ?? "",
                                                   createDate: dateTimestamp as! Date,
					                               doesReload: true,
                                                   reverseOrder: false)
				}
			}
		})
	}

	/// Collecting all the data store it
	func collectData()
	{
		self.items = [
            ModelCollectionFlowLayout(title: "Album", image: ImageAsset.image_icon.image),
            ModelCollectionFlowLayout(title: "Timeline", image: ImageAsset.timeline_icon.image),
            ModelCollectionFlowLayout(title: "Family Setting", image: ImageAsset.setting_icon.image),
		]
	}
    
    /// shows side menu bar
    ///
    /// - Parameter sender: touch the side menu bar
    @IBAction func SideMenuButtonTouched(_: Any)
    {
        performSegue(withIdentifier: FamilyMainPageViewController.SHOW_SIDE_MENU_VIEW, sender: self)
    }

	/// - Parameter collectionView: The collection view requesting this information.
	/// - Returns: The number of sections in collectionView.
	func numberOfSections(in _: UICollectionView) -> Int
	{
		return 1
	}

	/// - Parameters:
	///   - collectionView: The collection view requesting this information.
	///   - section: An index number identifying a section in collectionView.
	/// - Returns: The number of rows in section.
	func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int
	{
		return self.items.count
	}

	var vc: UIViewController?

	///
	/// - Parameters:
	///   - collectionView: The collection view requesting this information.
	///   - section: An index number identifying a section in collectionView.
	func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath)
	{
		let funct = self.items[(indexPath as NSIndexPath).row]

		if funct.title == "Album"
		{
			// shows album covers view controller
			performSegue(withIdentifier: FamilyMainPageViewController.SHOW_ALBUM_COVERS_VIEW, sender: nil)
		}
        
        if funct.title == "Timeline"
        {
            // shows album covers view controller
            performSegue(withIdentifier: FamilyMainPageViewController.SHOW_TIMELINE_VIEW, sender: nil)
        }
        
        if funct.title == "Family Setting"
        {
            // shows album covers view controller
            performSegue(withIdentifier: FamilyMainPageViewController.SHOW_FAMILY_SETTING_VIEW, sender: nil)
        }
	}

	///
	/// - Parameters:
	///   - collectionView: The collection view requesting this information.
	///   - section: An index number identifying a section in collectionView.
	/// - Returns: A configured cell object.
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
	{
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CarouselEffectCollectionViewCell
		cell.iconImage.image = self.items[indexPath.row].image
		cell.labelInf.text = self.items[indexPath.row].title
		return cell
	}

	func login()
	{
		/** @fn addAuthStateDidChangeListener:
		 @brief Registers a block as an "auth state did change" listener. To be invoked when:

		 + The block is registered as a listener,
		 + A user with a different UID from the current user has signed in, or
		 + The current user has signed out.

		 @param listener The block to be invoked. The block is always invoked asynchronously on the main
		 thread, even for it's initial invocation after having been added as a listener.

		 @remarks The block is invoked immediately after adding it according to it's standard invocation
		 semantics, asynchronously on the main thread. Users should pay special attention to
		 making sure the block does not inadvertently retain objects which should not be retained by
		 the long-lived block. The block itself will be retained by FIRAuth until it is
		 unregistered or until the FIRAuth instance is otherwise deallocated.

		 @return A handle useful for manually unregistering the block as a listener.
		 */
		Auth.auth().addStateDidChangeListener
		{ auth, user in
			// when current user is sign out

			if auth.currentUser == nil
			{
				self.askForLogin()
			}
			else
			{
				//                self.loadName()

				print("ELSE I'm here : " + (user?.email)!)

				self.loadUserAndFamilyDataForServer()
 
			}
			print("Listener get called ")
		}
	}

	///
	/// Get uers' infomation from server
	private func loadUserInfoFromServer()
	{
		// start pulling data from server : user info
        RegisterDBController.getInstance().getUserInfo(completion: {
			relation, dob, _, gender, name, photoPath,photoExt , error in

			if let error = error
			{
				print("get User Info from server error " + error.localizedDescription)
			}
			else
			{
				self.familyPosition = relation
                self.DOB = dob
                self.name = name
                self.gender = gender
                self.profileURL = photoPath
                self.profileExtension = photoExt
                
                if self.familyPosition == ""{
                     let alertController = UIAlertController(title: "Complete Your Profile", message: "Your haven't set your family position", preferredStyle: .alert)
                       alertController.addAction(UIAlertAction(title: "Skip", style: .default))
                       alertController.addAction(UIAlertAction(title: "Go Setting", style: .default, handler: { (_: UIAlertAction!) in
                            self.pushToProfileSetting()
                       }))

                    self.present(alertController, animated: true, completion: nil)
                }
                
                
                
//                print(" self.userDOB", dob)
				 
			}
		})
	}
    
    private func pushToProfileSetting(){

        if let profileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController {
            if let navigator = navigationController {
                print(" ProfileViewController prepare : pass success !")
                let userInformation = getUserInformation()
                profileVC.userInformation = userInformation
                navigator.pushViewController(profileVC, animated: true)
            }
        }
    }

	/// Get family's information from server
	private func loadFamilyInfoFromServer()
	{
		// start pulling data from server : family info
		RegisterDBController.getInstance().getFamilyInfo(completion: {
			uid, motto, name, profileUId, profileExtension, error in

			if let err = error
			{
				print("get family info from server error " + err.localizedDescription)
			}
			else
			{
				print("get family info from server success : ")

				self.familyUID = uid
				self.familyMotto.text = motto
                self.familyName.text = name

				if self.familyProfileUID != profileUId
				{
					// profileImageChanged, reload stuffs
					Util.GetImageData(imageUID: profileUId, UIDExtension: profileExtension, completion: {
						data in

						if let d = data
						{
							self.familyProfileImg.image = UIImage(data: d)
						}
						else
						{
							self.familyProfileImg.image = ImageAsset.default_image.image
						}
					})
				}

				self.familyProfileUID = profileUId
				self.familyProfileExtension = profileExtension
			}
		})
	}

	/// Get all the user and family data
	private func loadUserAndFamilyDataForServer()
	{
		print("loading user info !!! from login")
		self.loadFamilyInfoFromServer()
		self.loadUserInfoFromServer()
	}

	/// user asked for login
	private func askForLogin()
	{
		CacheHandler.getInstance().cleanCache()
		guard let VC1 = UIApplication.getTopViewController()?.storyboard!.instantiateViewController(withIdentifier: "LoginViewController") else { return }
		let navController = UINavigationController(rootViewController: VC1) // Creating a navigation controller with VC1 at the root of the navigation stack.
		present(navController, animated: true, completion: nil)
	}
}
