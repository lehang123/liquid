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


struct ModelCollectionFlowLayout {
    var title: String = ""
    var image: UIImage!
}

class FamilyMainPageViewController: UIViewController {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var profileImgContainer: UIView!
    @IBOutlet var carouselCollectionView: UICollectionView!
 
//    @IBAction func sideMenuClic(_ sender: Any) {
//        print("hahahahhaha")
//    }
    // Side menu effect
//    @IBAction func sideMenuClick(_ sender: Any) {
////        let menu = UISideMenuNavigationController(rootViewController: SideMenuTableViewController())
////
////        // reset side menu length
////        var settings = SideMenuSettings()
////        settings.menuWidth = CGFloat(270)
////        SideMenuManager.default.leftMenuNavigationController?.settings = settings
////
////        print("hahahahha")
////
////        present(menu, animated: true, completion: nil)
////
//    }


    
    var items = [ModelCollectionFlowLayout]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // check if client login
        //login()
        
        // loading profileImage as circle and with shadow
        let imageCornerRadious = profileImgContainer.frame.size.width/2

        profileImg.applyshadowWithCorner(containerView: profileImgContainer, cornerRadious: imageCornerRadious, color: UIColor.selfcGrey, opacity: 0.7, offSet: CGSize(width: 10, height: 10))
        
        // carousel effect
        collectData()
        self.carouselCollectionView.showsHorizontalScrollIndicator = false
        carouselCollectionView.register(UINib.init(nibName: "CarouselEffectCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        
        let flowLayout = UPCarouselFlowLayout()
        flowLayout.itemSize = CGSize(width: 120.0, height: carouselCollectionView.frame.size.height)
        flowLayout.scrollDirection = .horizontal
        flowLayout.sideItemScale = 0.8
        flowLayout.sideItemAlpha = 1.0
        flowLayout.spacingMode = .fixed(spacing: 5.0)
        carouselCollectionView.collectionViewLayout = flowLayout

      
    }
    
    func login(){
        let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
        let navController = UINavigationController(rootViewController: VC1) // Creating a navigation controller with VC1 at the root of the navigation stack.
        self.present(navController, animated:true, completion: nil)
//        let loginViewController = (self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController"))!
//        self.present(loginViewController, animated: true, completion: nil)
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    func collectData(){
        items = [
            ModelCollectionFlowLayout(title: "homeIcon", image: UIImage(named: "homeIcon")),
            ModelCollectionFlowLayout(title: "settingIcon", image: UIImage(named: "settingIcon")),
            ModelCollectionFlowLayout(title: "imageIcon", image: UIImage(named: "imageIcon")),
        ]
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let layout = self.carouselCollectionView.collectionViewLayout as! UPCarouselFlowLayout
        let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
        let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
    }
    
    fileprivate var currentPage: Int = 0 {
        didSet {
            print("page at centre = \(currentPage)")
        }
    }
    
    fileprivate var pageSize: CGSize {
        let layout = self.carouselCollectionView.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        if layout.scrollDirection == .horizontal {
            pageSize.width += layout.minimumLineSpacing
        } else {
            pageSize.height += layout.minimumLineSpacing
        }
        return pageSize
    }
}
    
extension FamilyMainPageViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let funct = items[(indexPath as NSIndexPath).row]
        
            if funct.title == "homeIcon" {
                // through code
//                let vc = SettingViewController()
//                self.navigationController?.pushViewController(vc, animated: true)
                
                // through storyboard
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "SettingViewController")
                self.navigationController!.pushViewController(vc, animated: true) // this line shows error
    
            }
        
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CarouselEffectCollectionViewCell
        cell.iconImage.image = items[indexPath.row].image
        cell.labelInf.text = items[indexPath.row].title
        return cell
    }
}

extension UIView {
    // apply shadow to round corner image
    func applyshadowWithCorner(containerView : UIView, cornerRadious : CGFloat, color: UIColor,opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1){
        containerView.clipsToBounds = false
        containerView.layer.shadowColor = color.cgColor
        containerView.layer.shadowOpacity = opacity
        containerView.layer.shadowOffset = offSet
        containerView.layer.shadowRadius = radius
        containerView.layer.cornerRadius = cornerRadious
        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: cornerRadious).cgPath
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadious
    }
    
}
