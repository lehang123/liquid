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
       test()
        
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
            // through code
            //                let vc = SettingViewController()
            //                self.navigationController?.pushViewController(vc, animated: true)
            
            // through storyboard
            let storyboard = UIStoryboard(name: "Main", bundle: nil)

            if vc == nil {
            vc = storyboard.instantiateViewController(withIdentifier: "AlbumCoverViewController")
            }
            self.navigationController!.pushViewController(vc!, animated: true) // this line shows error
            
        }

    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CarouselEffectCollectionViewCell
        cell.iconImage.image = items[indexPath.row].image
        cell.labelInf.text = items[indexPath.row].title
        return cell
    }
    
    func test (){
        
        //        AlbumDBController.getInstance().addNewAlbum(albumName: "gogogo", description: "gogogo test");
        
        //        AlbumDBController.getInstance().addPhotoToAlbum(desc: "halo wamg test", ext: ".zip", albumUID: "1M9uyYemU1VWTm8ZkRGZ", mediaPath: "somewhere_in_my_heart_halohalo.zip");
        ///
        //        AlbumDBController.getInstance().addAlbumSnapshotListener();

//        CacheHandler.getInstance().setCache(obj:"a" as AnyObject, forKey: 1 as AnyObject);
//        print("Before update : " + (CacheHandler.getInstance().getCache(forKey: 1 as AnyObject) as! String));
//        CacheHandler.getInstance().setCache(obj:"bb"as AnyObject, forKey: 1 as AnyObject);
//        print("After update : " + (CacheHandler.getInstance().getCache(forKey: 1 as AnyObject) as! String));
//        CacheHandler.getInstance().cleanCache();
//        print("After update2 : " + (CacheHandler.getInstance().getCache(forKey: 1 as AnyObject) as! String));


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

