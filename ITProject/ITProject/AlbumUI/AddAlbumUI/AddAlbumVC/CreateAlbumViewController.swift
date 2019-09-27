//
//  CreateAlbumViewController.swift
//  ITProject
//
//  Created by Gong Lehan on 27/9/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit

class CreateAlbumViewController: UIViewController {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var albumNameTextField: UITextField!
    @IBOutlet weak var albumDescriptionTextView: UITextView!
    @IBOutlet weak var addPhotosCollectionView: DynamicHeightCollectionView!
    
    var dummyPhotos = ["1", "2", "3", "1", "2", "3", "1", "2", "3", "1", "2", "3", "1", "2", "3", "1", "2", "3"]
    
    @IBAction func showLocationTapped(_ sender: Any) {
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        addPhotosCollectionView.delegate = self
        addPhotosCollectionView.dataSource = self
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
       layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 10, right: 20)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width/4, height: UIScreen.main.bounds.width/4)
       layout.minimumInteritemSpacing = 5
       layout.minimumLineSpacing = 5
       addPhotosCollectionView.collectionViewLayout = layout
        
    }
    
    
}

extension CreateAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    ///
    /// - Parameter collectionView: The collection view requesting this information.
    /// - Returns: the number of sections
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }


    ///
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - section: An index number identifying a section in collectionView.
    /// - Returns: The number of rows in section.
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return dummyPhotos.count
    }

    /// when album on clicked : open albumDetail controller
    /// - Parameters:
    ///   - collectionView: The collection view object that is notifying you of the selection change.
    ///   - indexPath: The index path of the cell that was selected.
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }

    /// called in viewDidLoad
    /// - Parameters:
    ///   - collectionView: The collection view object that is notifying you of the selection change.
    ///   - indexPath: The index path of the cell that was selected.
    /// - Returns: A configured cell object.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("how much time did you get called ")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddPhotoCollectionVewCell", for: indexPath) as! AddPhotoCollectionViewCell
        cell.TheImageView.image = #imageLiteral(resourceName: "item4")
        return cell
    }

}
