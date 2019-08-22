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
    
    struct Storyboard {
      
        static let albumDetailDescrpCell = "AlbumDetailDescrpCell"
        static let albumDetailPhotoCell = "AlbumDetailPhotoCell"
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false

//        title = albumd.name
        albumCoverImageView.image = albumd.getCoverImage()

        
        
        self.tableView.estimatedRowHeight = self.tableView.rowHeight
        self.tableView.rowHeight = UITableView.automaticDimension
        self.UpdateView()
        
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
            // 0 - Album Description
            // 1 - Album Photo detail
            return 2
        
    }
    

 
    func UpdateView() {
        tableView.backgroundColor = UIColor.white
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.rowHeight = UITableView.automaticDimension
        tableView.addSubview(headerView)
        
        updateHeaderlayout = CAShapeLayer()
        updateHeaderlayout.fillColor = UIColor.black.cgColor
        headerView.layer.mask = updateHeaderlayout
        
        let newheight = headerHeight - headerCut / 2
        tableView.contentInset = UIEdgeInsets(top: newheight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -newheight)
        
        self.Setupnewview()
    }
    
    func Setupnewview() {
        let newheight = headerHeight - headerCut / 2
        var headerframe = CGRect(x: 0, y: -newheight, width: tableView.bounds.width, height: headerHeight)
        if tableView.contentOffset.y < newheight
        {
            headerframe.origin.y = tableView.contentOffset.y
            headerframe.size.height = -tableView.contentOffset.y + headerCut / 2
        }
        
        headerView.frame = headerframe
        let cutdirection = UIBezierPath()
        cutdirection.move(to: CGPoint(x: 0, y: 0))
        cutdirection.addLine(to: CGPoint(x: headerframe.width, y: 0))
        cutdirection.addLine(to: CGPoint(x: headerframe.width, y: headerframe.height))
        cutdirection.addLine(to: CGPoint(x: 0, y: headerframe.height - headerCut))
        updateHeaderlayout.path = cutdirection.cgPath
        
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.tableView.decelerationRate = UIScrollView.DecelerationRate.fast
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.Setupnewview()
    }

    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.albumDetailDescrpCell, for: indexPath) as! AlbumDetailDescrpTableViewCell
            cell.descrp = albumd
            cell.selectionStyle = .none
            print("cell", cell)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.albumDetailPhotoCell, for: indexPath) as! AlbumDetailPhotoTableViewCell

            return cell
        }
    }

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


    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->CGFloat {
        if indexPath.row == 1 {
            return self.tableView.bounds.height
        } else {
            return UITableView.automaticDimension
        }
    }
}

// TODO: finish collection view controller
// MARK : UICollectionViewDataSource

extension AlbumDetailTableViewController: UICollectionViewDataSource
    {
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return albumd.getImageList().count
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.albumDetailPhotoCell, for: indexPath) as! AlbumDetailPhotoCollectionViewCell
           cell.image = albumd.getImageList()[indexPath.item]

            return cell
        }

    }

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

