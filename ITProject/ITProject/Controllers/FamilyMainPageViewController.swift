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

/// Structure
struct ModelCollectionFlowLayout
{
	var title: String = ""
	var image: UIImage!
}

/// Delegation goes here
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
	// Constants and properties go here
	private static let SHOW_ALBUM_COVERS_VIEW = "ShowAlbumCovers"
	private static let SHOW_SIDE_MENU_VIEW = "ShowSideMenuBar"
	private var familyUID: String!
	private var familyName: String?
	private var familyProfileUID: String?
	private var familyProfileExtension: String?
	private var userFamilyPosition: String?
	private var userGender: Gender?
	private var profileURL: String?
	private var profileExtension: String?

	@IBOutlet var familyMotto: UILabel!
	@IBOutlet var profileImg: EnhancedCircleImageView!
	@IBOutlet var profileImgContainer: UIView!
	@IBOutlet var carouselCollectionView: UICollectionView!

	/// shows side menu bar
	///
	/// - Parameter sender: touch the side menu bar
	@IBAction func SideMenuButtonTouched(_: Any)
	{
		performSegue(withIdentifier: FamilyMainPageViewController.SHOW_SIDE_MENU_VIEW, sender: self)
	}

	var items = [ModelCollectionFlowLayout]()

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
		self.profileImg.layer.shadowColor = UIColor.selfcGrey.cgColor
		self.profileImg.layer.shadowOpacity = 0.7
		self.profileImg.layer.shadowOffset = CGSize(width: 10, height: 10)
		self.profileImg.layer.shadowRadius = 1
		self.profileImg.clipsToBounds = false

		// carousel effect
		self.collectData()
		self.carouselCollectionView.showsHorizontalScrollIndicator = false
		self.carouselCollectionView.register(UINib(nibName: "CarouselEffectCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")

		let flowLayout = UPCarouselFlowLayout()
		flowLayout.itemSize = CGSize(width: self.carouselCollectionView.frame.size.width / 2.5, height: self.carouselCollectionView.frame.size.height)
		flowLayout.scrollDirection = .horizontal
		flowLayout.sideItemScale = 0.8
		flowLayout.sideItemAlpha = 1.0
		flowLayout.spacingMode = .fixed(spacing: 5.0)
		self.carouselCollectionView.collectionViewLayout = flowLayout
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
					let currentUser = Auth.auth().currentUser
					self.profileURL = currentUser?.photoURL?.deletingPathExtension().absoluteString
					self.profileExtension = currentUser?.photoURL?.pathExtension

					sideMenuVC.userInformation = UserInfo(
						username: Auth.auth().currentUser?.displayName ?? "anonymous",
						imageUID: self.profileURL ?? Util.DEFAULT_IMAGE,
						imageExtension: self.profileExtension ?? Util.EXTENSION_JPEG,
						phone: currentUser?.phoneNumber ?? "12345678",
						gender: self.userGender ?? Gender.Unknown,
						familyRelation: self.userFamilyPosition ?? "None",
						userInfoDelegate: self
					)

					// pass user's family info to the current sideMenuVC
					sideMenuVC.userFamilyInformation = UserFamilyInfo(
						familyUID: self.familyUID,
						familyName: self.familyName,
						familyProfileUID: self.familyProfileUID,
						familyProfileExtension: self.familyProfileExtension,
						familyMottoText: self.familyMotto.text,
						familyInfoDelegate: self
					)
				}
			}
		}
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
		CacheHandler.getInstance().getAlbumInfo(familyID: DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.FAMILY_COLLECTION_NAME, documentUID: self.familyUID), completion: {
			albumDic, error in
			if let err = error
			{
				print("error occurs during passAlbumsData : " + err.localizedDescription)
			}
			else
			{
				albumDic.forEach
				{
					arg in

					let (albumName, albumDetails) = arg
					albumDetailTVC.loadAlbumToList(title: albumName,
					                               description: albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_DESCRIPTION] as! String,
					                               UID: albumDetails[AlbumDBController.DOCUMENTID] as! String,
					                               coverImageUID: albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL] as? String,
					                               coverImageExtension: albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL_EXTENSION] as? String,
					                               doesReload: true,
					                               reveseOrder: false)
				}
			}
		})
	}

	/// Collecting all the data store it
	func collectData()
	{
		self.items = [
			ModelCollectionFlowLayout(title: "Album", image: UIImage(named: "imageIcon")),
			ModelCollectionFlowLayout(title: "settingIcon", image: UIImage(named: "settingIcon")),
			ModelCollectionFlowLayout(title: "imageIcon", image: UIImage(named: "imageIcon")),
		]
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
			// todo : we send the album covers data through the sender,
			// nil for now as we don't have any data
			performSegue(withIdentifier: FamilyMainPageViewController.SHOW_ALBUM_COVERS_VIEW, sender: nil)
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
		CacheHandler.getInstance().getUserInfo(completion: {
			relation, gender, _, error in

			if let err = error
			{
				print("get User Info from server error " + err.localizedDescription)
			}
			else
			{
				self.userFamilyPosition = relation
				self.userGender = gender
			}
		})
	}

	/// Get family's information from server
	private func loadFamilyInfoFromServer()
	{
		// start pulling data from server : family info
		CacheHandler.getInstance().getFamilyInfo(completion: {
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
				self.familyName = name

				if self.familyProfileUID != profileUId
				{
					// profileImageChanged, reload stuffs
					Util.GetImageData(imageUID: profileUId, UIDExtension: profileExtension, completion: {
						data in

						if let d = data
						{
							self.profileImg.image = UIImage(data: d)
						}
						else
						{
							self.profileImg.image = UIImage(named: Util.DEFAULT_IMAGE)
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
