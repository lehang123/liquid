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

class FamilyMainPageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private static let SHOW_ALBUM_COVERS_VIEW = "ShowAlbumCovers"
    
    @IBOutlet weak var profileImg: EnhancedCircleImageView!
    @IBOutlet weak var profileImgContainer: UIView!
    @IBOutlet var carouselCollectionView: UICollectionView!
 
    
    var items = [ModelCollectionFlowLayout]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                self.retrieveAlbums(albumDetailTVC: albumDetailTVC);
                
            }
        }}
        
//                print( CacheHandler.getInstance().getAlbums());
//                CacheHandler.getInstance().cacheAlbums();
//                var albumData :  Dictionary <String, Dictionary<String, Any>> = CacheHandler.getInstance().getCache(forKey: CacheHandler.ALBUM_DATA) as! Dictionary<String, Dictionary<String, Any>>;
//
//                albumData.forEach { arg in
//                    var albumName :String;
//                    var albumDetails :Dictionary<String, Any>;
//
//                    (albumName, albumDetails) = arg
//                    //get thumbnail path:
//                    var currentThumbnail : String = albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL] as! String;
//                    var currentThumbnailExt : String = albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL_EXTENSION] as! String;
//                    //TODO: replace arg to imageUID with currentThumbnail & currentThumbnailExt
//
//                    //download thumbnail photo:
//                    Util.GetImageData(imageUID: ("test-small-size-image"), completion: {
//
//                        data in
//                        var thumbnailImage : UIImage? = UIImage(data: data!)
//
//
//
//
//                        print("FamilyMainPageViewController prepare :: aaaa")
//                        //
//                        albumDetailTVC.loadAlbumToList(title: albumName, description: albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_DESCRIPTION] as! String, UID: Util.GenerateUDID(),
//                                                       photos: albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_MEDIAS] as! Array,
//                                                       coverImage: thumbnailImage,doesReload: false)
//                    })
//                }
               
                
                
            
    
    public func retrieveAlbums(albumDetailTVC : AlbumCoverViewController){
        var userData : [String:Any] = CacheHandler.getInstance().getCache(forKey: CacheHandler.USER_DATA) as! [String : Any];
        var familyDocumentReference : DocumentReference = userData[RegisterDBController.USER_DOCUMENT_FIELD_FAMILY] as! DocumentReference;
        //once found, get all albums related to family:
        DBController.getInstance().getDB().collection(AlbumDBController.ALBUM_COLLECTION_NAME).whereField(AlbumDBController.ALBUM_DOCUMENT_FIELD_FAMILY, isEqualTo: familyDocumentReference)
            .getDocuments() { (querySnapshot, error) in
                //error handle:
                if let error = error {
                    print("cacheAlbum Error getting documents: \(error)")
                    
                } else {
                    
                    var albums : Dictionary <String, Dictionary<String, Any>> = Dictionary <String, Dictionary<String,Any>> ();
                    //loop thru each document, parse them into the required data format:
                    for document in querySnapshot!.documents {
                        let albumDetails : [String:Any] = document.data();
                        let albumName :String = albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_NAME] as! String;
                        let owner:DocumentReference? = (albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_OWNER] as! DocumentReference);
                        //this is for the setCache:
                        albums[albumName] = [
                            AlbumDBController.ALBUM_DOCUMENT_FIELD_CREATED_DATE : albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_CREATED_DATE] as Any,
                            AlbumDBController.ALBUM_DOCUMENT_FIELD_OWNER : owner?.documentID as Any,
                            AlbumDBController.ALBUM_DOCUMENT_FIELD_MEDIAS : albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_MEDIAS]!,
                            AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL :albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL] as Any,
                            AlbumDBController.ALBUM_DOCUMENT_FIELD_DESCRIPTION :
                                albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_DESCRIPTION]!,
                            AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL_EXTENSION :
                                
                                albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL_EXTENSION] as Any,
                            AlbumDBController.DOCUMENTID : document.documentID
                            
                        ]
                        //this is for the album view:
                        //get thumbnail photo:
                        
                        //get thumbnail path:
                        var currentThumbnail : String? = albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL] as? String;
                        var currentThumbnailExt : String? = albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL_EXTENSION] as? String;
                        //TODO: replace arg to imageUID with currentThumbnail & currentThumbnailExt
                        
                        //download thumbnail photo:
                        
                        Util.GetImageData(imageUID: ("test-small-size-image"), completion: {
                            
                            data in
                            var thumbnailImage : UIImage? = UIImage(data: data!)
                            
                            
                            
                            
                            print("FamilyMainPageViewController prepare :: aaaa")
                            albumDetailTVC.loadAlbumToList(title: albumName, description: albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_DESCRIPTION] as! String, UID: document.documentID,
                                                           photos: albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_MEDIAS] as! Array,
                                                           coverImage: thumbnailImage,doesReload: true)
                        })
                        
                       
                    }
                    
                    CacheHandler.getInstance().setCache(obj: albums as AnyObject, forKey: CacheHandler.ALBUM_DATA as AnyObject);
                    
                    
                }}
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
    
    func test (){
        Util.DeleteFileFromServer(fileName: "8E6A110F-7447-4CC3-B0C8-EB4F726C64EA",
                                  fextension: Util.EXTENSION_JPEG)

    }

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
//    func test (){
//
//
//

//        //        AlbumDBController.getInstance().addNewAlbum(albumName: "gogogo", description: "gogogo test");
//
//        //        AlbumDBController.getInstance().addPhotoToAlbum(desc: "halo wamg test", ext: ".zip", albumUID: "1M9uyYemU1VWTm8ZkRGZ", mediaPath: "somewhere_in_my_heart_halohalo.zip");
//        ///
//        //        AlbumDBController.getInstance().addAlbumSnapshotListener();
//        var x:CacheHandler  = CacheHandler();
//        var y :CacheHandler = CacheHandler();
//        x.setCache(obj: "halo" as AnyObject, forKey: 0 as AnyObject);
//        y.setCache(obj: "hihi" as AnyObject, forKey: 1 as AnyObject);
//        print( "x index 0::: " + ( x.getCache(forKey: 0 as AnyObject ) as! String));
//        print( "y index 1::: " + (y.getCache(forKey: 1 as AnyObject ) as! String));
//    }
//}


