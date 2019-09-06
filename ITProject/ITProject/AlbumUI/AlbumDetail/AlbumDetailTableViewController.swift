//
//  AlbumDetailTableViewController.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/16.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit

class AlbumDetailTableViewController: UITableViewController {
    var albumd: AlbumDetail!
    
    @IBOutlet weak var albumCoverImageView: UIImageView!
    var headerView : UIView!
    var updateHeaderlayout : CAShapeLayer!
    
    private let headerHeight : CGFloat = 300
    private let headerCut : CGFloat = 80
    
    // imagePicker that to open photos library
    private var imagePicker = UIImagePickerController()
    
    /// Description
    struct Storyboard {
      
        static let albumDetailDescrpCell = "AlbumDetailDescrpCell"
        static let albumDetailPhotoCell = "AlbumDetailPhotoCell"
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false
        
        let addPhotos = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPhotosTapped))
        self.navigationItem.rightBarButtonItem = addPhotos

//        title = albumd.name
        albumCoverImageView.image = albumd.getCoverImage()

        self.tableView.estimatedRowHeight = self.tableView.rowHeight
        self.tableView.rowHeight = UITableView.automaticDimension
        
        headerView = tableView.tableHeaderView
        updateHeaderlayout = CAShapeLayer()
        self.UpdateView(headerView: headerView, updateHeaderlayout: updateHeaderlayout, headerHeight: headerHeight, headerCut: headerCut)
        
    }
    
    @objc private  func addPhotosTapped(){
        print("addPhotosTapped : Tapped")
        // pop gallery here
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion:  nil)
    }
    
    // MARK: - Table view data source

    /// Description
    ///
    /// - Parameters:
    ///   - tableView: <#tableView description#>
    ///   - section: section description
    /// - Returns: return value description
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
            // 0 - Album Description
            // 1 - Album Photo detail
            return 2
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.tableView.decelerationRate = UIScrollView.DecelerationRate.fast
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.Setupnewview(headerView: headerView, updateHeaderlayout: updateHeaderlayout, headerHeight: headerHeight, headerCut: headerCut)
    }

    

    /// <#Description#>
    ///
    /// - Parameters:
    ///   - tableView: <#tableView description#>
    ///   - indexPath: <#indexPath description#>
    /// - Returns: <#return value description#>
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.albumDetailDescrpCell, for: indexPath) as! AlbumDetailDescrpTableViewCell
            cell.descrp = albumd
            cell.selectionStyle = .none
            print("AlbumDetailTableViewController.tableView.cell :::", cell)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.albumDetailPhotoCell, for: indexPath) as! AlbumDetailPhotoTableViewCell

            return cell
        }
    }

    /// <#Description#>
    ///
    /// - Parameters:
    ///   - tableView: <#tableView description#>
    ///   - cell: <#cell description#>
    ///   - indexPath: <#indexPath description#>
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if indexPath.row == 1 {
            if let cell = cell as? AlbumDetailPhotoTableViewCell {
                cell.photoCollectionView.dataSource = self
                cell.photoCollectionView.delegate = self
                cell.photoCollectionView.reloadData()
                cell.photoCollectionView.isScrollEnabled = true
                
            }
        }
    }


    /// <#Description#>
    ///
    /// - Parameters:
    ///   - tableView: <#tableView description#>
    ///   - indexPath: <#indexPath description#>
    /// - Returns: <#return value description#>
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->CGFloat {
        if indexPath.row == 1 {
            return self.tableView.bounds.height
        } else {
            return UITableView.automaticDimension
        }
    }
}


extension AlbumDetailTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    /* delegate function from the UIImagePickerControllerDelegate
     called when choose button pressed
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       
        self.dismiss(animated: true, completion: { () -> Void in
             print ("imagePickerController: Did picked pressed !!")
        })
        
    }
    
    /* delegate function from the UIImagePickerControllerDelegate
     called when canceled button pressed, get out of photo library
     */
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.dismiss(animated: true, completion: { () -> Void in
            print ("imagePickerController: Did canceled pressed !!")
        })
    }
}
// TODO: finish collection view controller
// MARK : UICollectionViewDataSource

extension AlbumDetailTableViewController: UICollectionViewDataSource
    {
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return albumd.getPhotos().count
        }

        /* photos cell that display photos' thumbnail */
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.albumDetailPhotoCell, for: indexPath) as! AlbumDetailPhotoCollectionViewCell
//           cell.image = albumd.getImageList()[indexPath.item]
            
            let photo = albumd.getPhotos()[indexPath.item]

            print("AlbumDetailTableViewController : displaying thumbnail : " + photo.getUID())
            
            
            Util.GetImageData(imageUID: photo.getUID(), completion: {
                data in
                if data != nil{
                    cell.image = UIImage(data: data!)
                }
            })

            return cell
        }
    }

// MARK: - <#UICollectionViewDelegate, UICollectionViewDelegateFlowLayout#>
extension AlbumDetailTableViewController : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
    {
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
        {
            let layout = collectionViewLayout as! UICollectionViewFlowLayout
            layout.minimumLineSpacing = 5.0
            layout.minimumInteritemSpacing = 2.5
            let itemWidth = (collectionView.bounds.width - 5.0) / 2.0
            return CGSize(width: itemWidth, height: itemWidth)
        }
}

