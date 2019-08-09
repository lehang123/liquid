//
//  FamilyMainPageViewController.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/8.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit


struct ModelCollectionFlowLayout {
    var title: String = ""
    var image: UIImage!
}

class FamilyMainPageViewController: UIViewController {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var profileImgContainer: UIView!
    @IBOutlet var carouselCollectionView: UICollectionView!
    
    var arrData = [ModelCollectionFlowLayout]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // loading profileImage as circle and with shadow
        let imageCornerRadious = profileImgContainer.frame.size.width/2

        profileImg.applyshadowWithCorner(containerView: profileImgContainer, cornerRadious: imageCornerRadious, color: UIColor.selfcGrey, opacity: 0.7, offSet: CGSize(width: 10, height: 10))
        
        
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
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    func collectData(){
        arrData = [
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CarouselEffectCollectionViewCell
        cell.iconImage.image = arrData[indexPath.row].image
        cell.labelInf.text = arrData[indexPath.row].title
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
