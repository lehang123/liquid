//
//  StickyHeaderTableViewExtension.swift
//  ITProject
//
//  Created by Gong Lehan on 22/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewController {
    
    func UpdateView(headerView : UIView, updateHeaderlayout : CAShapeLayer, headerHeight : CGFloat, headerCut : CGFloat) {
        tableView.backgroundColor = UIColor.white
        tableView.tableHeaderView = nil
        tableView.rowHeight = UITableView.automaticDimension
        tableView.addSubview(headerView)
        
        updateHeaderlayout.fillColor = UIColor.black.cgColor
        headerView.layer.mask = updateHeaderlayout
        
        let newheight = headerHeight - headerCut / 2
        tableView.contentInset = UIEdgeInsets(top: newheight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -newheight)
        
        self.Setupnewview(headerView: headerView,
                          updateHeaderlayout: updateHeaderlayout,
                          headerHeight: headerHeight,
                          headerCut: headerCut)
    }
    
    func Setupnewview(headerView : UIView, updateHeaderlayout : CAShapeLayer, headerHeight : CGFloat, headerCut : CGFloat, headerStopAt : CGFloat=0){
        let newheight = headerHeight - headerCut / 2
        var headerframe = CGRect(x: 0, y: -newheight, width: tableView.bounds.width, height: headerHeight)
        if tableView.contentOffset.y < newheight
        {
            headerframe.origin.y = tableView.contentOffset.y
            headerframe.size.height = -tableView.contentOffset.y + headerCut / 2
        }
        
        if tableView.contentOffset.y > (-headerStopAt)
        {
            headerframe.origin.y = tableView.contentOffset.y
            headerframe.size.height = headerStopAt
        }
        
        
        headerView.frame = headerframe
        let cutdirection = UIBezierPath()
        cutdirection.move(to: CGPoint(x: 0, y: 0))
        cutdirection.addLine(to: CGPoint(x: headerframe.width, y: 0))
        cutdirection.addLine(to: CGPoint(x: headerframe.width, y: headerframe.height))
        cutdirection.addLine(to: CGPoint(x: 0, y: headerframe.height - headerCut))
        updateHeaderlayout.path = cutdirection.cgPath
    }
    
//    func Setupnewview(headerView : UIView, updateHeaderlayout : CAShapeLayer, headerHeight : CGFloat, headerCut : CGFloat) {
//
//
//        Setupnewview(headerView: headerView, updateHeaderlayout: updateHeaderlayout, headerHeight: headerHeight, headerCut: headerCut, headerStopAt: 0)
//
//    }
}
