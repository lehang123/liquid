//
//  FamilyMainPageViewController.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/8.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit

import SideMenu
import UPCarouselFlowLayout
import FirebaseStorage
import Firebase
import EnhancedCircleImageView


struct ModelCollectionFlowLayout {
    var title: String = ""
    var image: UIImage!
}

protocol FamilyProfileViewDelegate {
    func didUpdateFamilyInfo()
}

protocol UserProfileViewDelegate {
    func didUpdateUserInfo()
}

class FamilyMainPageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, FamilyProfileViewDelegate, UserProfileViewDelegate  {
    
    private static let SHOW_ALBUM_COVERS_VIEW = "ShowAlbumCovers"
    private static let SHOW_SIDE_MENU_VIEW = "ShowSideMenuBar"
    
    @IBOutlet weak var familyMotto: UILabel!
    @IBOutlet weak var profileImg: EnhancedCircleImageView!
    @IBOutlet weak var profileImgContainer: UIView!
    @IBOutlet var carouselCollectionView: UICollectionView!
    
    private var familyUID: String!
    private var familyName: String?
    private var familyProfileUID: String?
    private var familyProfileExtension: String?

    private var userFamilyPosition: String?
    private var userGender: Gender?
    
//    var userInfo: String!
//    var userImageUID: String!
//    var userImageExtension: String!
 
    @IBAction func SideMenuButtonTouched(_ sender: Any) {
        
        //shows side menu bar
        self.performSegue(withIdentifier: FamilyMainPageViewController.SHOW_SIDE_MENU_VIEW, sender: self)
        
    }
    
    var items = [ModelCollectionFlowLayout]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did loaded called")
        login()
        
        self.navigationController?.navigationBar.items?.forEach{
            (item) in
            item.leftBarButtonItem?.tintColor = UIColor.black
        }
        
        //testing functions. dont forget to delete!::
//       test()
        
        // set Profile Image
        profileImg.image = UIImage(named: "tempProfileImage")
        // loading profileImage with shadow
        profileImg.layer.shadowColor = UIColor.selfcGrey.cgColor
        profileImg.layer.shadowOpacity = 0.7
        profileImg.layer.shadowOffset = CGSize(width: 10, height: 10)
        profileImg.layer.shadowRadius = 1
        profileImg.clipsToBounds = false
        
        
        // carousel effect
        self.collectData()
        self.carouselCollectionView.showsHorizontalScrollIndicator = false
        carouselCollectionView.register(UINib.init(nibName: "CarouselEffectCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        
        let flowLayout = UPCarouselFlowLayout()
        flowLayout.itemSize = CGSize(width: (carouselCollectionView.frame.size.width)/2.5, height: carouselCollectionView.frame.size.height)
        flowLayout.scrollDirection = .horizontal
        flowLayout.sideItemScale = 0.8
        flowLayout.sideItemAlpha = 1.0
        flowLayout.spacingMode = .fixed(spacing: 5.0)
        carouselCollectionView.collectionViewLayout = flowLayout

    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == FamilyMainPageViewController.SHOW_ALBUM_COVERS_VIEW {
            if let albumDetailTVC = segue.destination as? AlbumCoverViewController {
                // todo : pass cache here !!!!
                print(" FamilyMainPageViewController prepare : pass success !");
                self.passAlbumsData(to: albumDetailTVC)
            }
        }
    else if segue.identifier == FamilyMainPageViewController.SHOW_SIDE_MENU_VIEW {
        if let sideMenuNC = segue.destination as? UISideMenuNavigationController {
            if let sideMenuVC = sideMenuNC.visibleViewController as? SideMenuTableViewController{
                
                    print(" FamilyMainPageViewController prepare : UISideMenuNavigationController !")
                
                // pass user info to the current sideMenuVC
                    let currentUser = Auth.auth().currentUser
                    let profileURL = currentUser?.photoURL
                    let profileExtension = profileURL?.pathExtension
                    let profileUID = profileURL?.deletingPathExtension().absoluteString
                
                    sideMenuVC.userInformation = UserInfo(
                    username: currentUser?.displayName ?? "placeHolder",
                    imageUID: profileUID ?? "test-small-size-image",
                    imageExtension: profileExtension ?? Util.EXTENSION_JPEG,
                    phone: currentUser?.phoneNumber ?? "12345678",
                    gender: self.userGender ?? Gender.Unknown,
                    familyRelation: self.userFamilyPosition ?? "None",
                    userInfoDelegate: self)
                
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
    
    func didUpdateFamilyInfo() {
        // reload Family Info
        if Auth.auth().currentUser != nil{
            self.loadFamilyInformFromServer()
        }
    }
    
    func didUpdateUserInfo() {
        // reload User Info
        if Auth.auth().currentUser != nil{
            self.loadUserInformFromServer()
        }
    }
    
    private func passAlbumsData(to albumDetailTVC: AlbumCoverViewController){
        //start pulling data from server : albums info
        CacheHandler.getInstance().getAlbumInfo(familyID: DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.FAMILY_COLLECTION_NAME, documentUID: familyUID) , completion: {
            albumDic, error in
            if let err = error {
                print("error occurs during passAlbumsData : " + err.localizedDescription)
            }else{
                albumDic?.forEach({
                    (arg) in
                    
                    let (albumName, albumDetails) = arg
                    albumDetailTVC.loadAlbumToList(title: albumName,
                                                   description:albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_DESCRIPTION] as! String,
                                                   UID: albumDetails[AlbumDBController.DOCUMENTID] as! String,
                                                   photos: albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_MEDIAS] as? Array,
                                                   coverImageUID: albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL] as? String,
                                                   coverImageExtension: albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL_EXTENSION] as? String,
                                                   doesReload: true)
                    
                })
            }
        })
    }

    
    func collectData(){
        items = [
            ModelCollectionFlowLayout(title: "Album", image: UIImage(named: "imageIcon")),
            ModelCollectionFlowLayout(title: "settingIcon", image: UIImage(named: "settingIcon")),
            ModelCollectionFlowLayout(title: "imageIcon", image: UIImage(named: "imageIcon")),
        ]
    }

    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    var vc : UIViewController?

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let funct = items[(indexPath as NSIndexPath).row]
        
        if funct.title == "Album" {
            // shows album covers view controller
            // todo : we send the album covers data through the sender,
            // nil for now as we don't have any data
            self.performSegue(withIdentifier: FamilyMainPageViewController.SHOW_ALBUM_COVERS_VIEW, sender: nil)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CarouselEffectCollectionViewCell
        cell.iconImage.image = items[indexPath.row].image
        cell.labelInf.text = items[indexPath.row].title
        return cell
    }
    
    func login(){
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
        Auth.auth().addStateDidChangeListener { (auth, user) in
            // when current user is sign out
            
            if auth.currentUser == nil {
                self.askForLogin()
            }else{
//                self.loadName()
                
                print("ELSE I'm here : " + (user?.email)!)
                
                self.loadUserAndFamilyDataForServer()
            
            }
            print("Listener get called ")
        }
    }
    
    private func loadUserInformFromServer(){
        //start pulling data from server : user info
        CacheHandler.getInstance().getUserInfo(completion: {
            relation, gender, _, error in
            
            if let err = error{
                print("get User Info from server error " + err.localizedDescription)
            }else {
                self.userFamilyPosition = relation
                self.userGender = gender
            }
        })
    }
    
    private func loadFamilyInformFromServer(){
        //start pulling data from server : family info
        CacheHandler.getInstance().getFamilyInfo(completion: {
            uid, motto, name, profileUId, profileExtension, error in
            
            if let err = error {
                print("get family info from server error " + err.localizedDescription)
            }else {
                print("get family info from server success : ")
                
                self.familyUID = uid
                self.familyMotto.text = motto
                self.familyName = name
                self.familyProfileUID = profileUId
                self.familyProfileExtension = profileExtension
            }
        })
    }
    
    private func loadUserAndFamilyDataForServer(){
        
        loadFamilyInformFromServer()
        loadUserInformFromServer()
//        //start pulling data from server : family info
//        CacheHandler.getInstance().getFamilyInfo(completion: {
//            uid, motto, name, profileUId, profileExtension, error in
//
//            if let err = error {
//                print("get family info from server error " + err.localizedDescription)
//            }else {
//                print("get family info from server success : ")
//
//                self.familyUID = uid
//                self.familyMotto.text = motto
//                self.familyName = name
//                self.familyProfileUID = profileUId
//                self.familyProfileExtension = profileExtension
//            }
//        })
//
//        //start pulling data from server : user info
//        CacheHandler.getInstance().getUserInfo(completion: {
//            relation, gender, _, error in
//
//            if let err = error{
//                print("get User Info from server error " + err.localizedDescription)
//            }else {
//                self.userFamilyPosition = relation
//                self.userGender = gender
//            }
//        })
    }
    
    private func askForLogin(){
        guard let VC1 = UIApplication.getTopViewController()?.storyboard!.instantiateViewController(withIdentifier: "LoginViewController") else { return }
        let navController = UINavigationController(rootViewController: VC1) // Creating a navigation controller with VC1 at the root of the navigation stack.
        self.present(navController, animated:true, completion: nil)
    }
    
    func test (){
//        Util.DeleteFileFromServer(fileName: "8E6A110F-7447-4CC3-B0C8-EB4F726C64EA",
//                                  fextension: Util.EXTENSION_JPEG)
        AlbumDBController.getInstance().addPhotoToAlbum(desc : "me me she", ext : ".jpg", albumUID : "0CiJH0s3tWLo2PwCNVYE", mediaPath: "iloveyou", dateCreated : Timestamp(date: Date()));
        AlbumDBController.getInstance().UpdateComments(username: Auth.auth().currentUser!.uid, comment: "hahahah", photoUID: "iloveyou");
        AlbumDBController.getInstance().UpdateComments(username: Auth.auth().currentUser!.uid, comment: "HALO 2 I LOVE YOU ", photoUID: "iloveyou");

        AlbumDBController.getInstance().UpdateComments(username: Auth.auth().currentUser!.uid, comment: "PERFECT", photoUID: "iloveyou");
        AlbumDBController.getInstance().UpdateComments(username: Auth.auth().currentUser!.uid, comment: "HALO 2 I LOVE YOU ", photoUID: "iloveyou");
    }


    
//extension FamilyMainPageViewController: UICollectionViewDelegate, UICollectionViewDataSource{
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return items.count
//    }
//

//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let funct = items[(indexPath as NSIndexPath).row]
//
//            if funct.title == "Album" {
//                // through code
////                let vc = SettingViewController()
////                self.navigationController?.pushViewController(vc, animated: true)
//
//                // through storyboard
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let vc = storyboard.instantiateViewController(withIdentifier: "AlbumCoverViewController")
//                self.navigationController!.pushViewController(vc, animated: true) // this line shows error
//
//            }

//    }
//
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CarouselEffectCollectionViewCell
//        cell.iconImage.image = items[indexPath.row].image
//        cell.labelInf.text = items[indexPath.row].title
//        return cell
//    }
//
}


