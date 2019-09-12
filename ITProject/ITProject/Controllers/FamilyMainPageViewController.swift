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
        collectData()
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
                print( CacheHandler.getInstance().getAlbums());
                
                // todo : Add UID here , as it's random for now
                CacheHandler.getInstance().getAlbums().forEach({
                    (arg) in
                    
                    let (key, value) = arg
                    //parse in the photos details:
                    let t : NSArray = value[AlbumDBController.ALBUM_DOCUMENT_FIELD_MEDIAS] as! NSArray;
                    var g : DocumentReference?;
                    var photos: [PhotoDetail] = [PhotoDetail]() ;
                    print("values for photos ::: ", value[AlbumDBController.ALBUM_DOCUMENT_FIELD_MEDIAS]);
                    t.forEach({ (item) in
                        g = item as? DocumentReference;
                        g?.getDocument(completion: { (doc, Error) in
                            var currData: [String: Any] = (doc?.data())!;
                            
                            //TODO: fill in comments (don't put as nil),
                            photos.append(PhotoDetail(title: doc?.documentID, description: currData[AlbumDBController.MEDIA_DOCUMENT_FIELD_DESCRIPTION] as! String, UID: doc?.documentID, likes: currData[AlbumDBController.MEDIA_DOCUMENT_FIELD_LIKES] as? Int, comments: nil ))
                            
                            print("prepare::: photos");

                            
                            
                        })
                        
                    })
                    
                    
                    
                    var thumbnailImage:UIImage?
                    
                    // before assigining, download thumbnail first :
                    Util.GetImageData(imageUID: ("test-small-size-image"), completion: {
                        
                        data in
                        thumbnailImage = UIImage(data: data!)
                        
                        
                        //pass in all photos in photos array:
                        
                        albumDetailTVC.loadAlbumToList(title: key, description: value[AlbumDBController.ALBUM_DOCUMENT_FIELD_DESCRIPTION] as! String, UID: Util.GenerateUDID(),
                                                       photos: photos,
                                                       coverImage: thumbnailImage)
                        
                        
                        
                    })
                    
                })
            }
        }
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

