//
//  StickyHeaderTableViewExtension.swift
//  ITProject
//
//  Created by Gong Lehan on 14/9/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    
    func UpdateView(headerView : UIView, updateHeaderlayout : CAShapeLayer, headerHeight : CGFloat, headerCut : CGFloat) {
        self.backgroundColor = UIColor.white
        self.tableHeaderView = nil
        self.rowHeight = UITableView.automaticDimension
        
        self.frame = headerView.bounds
        self.addSubview(headerView)
       
        
        updateHeaderlayout.fillColor = UIColor.black.cgColor
        headerView.layer.mask = updateHeaderlayout
        
        let newheight = headerHeight - headerCut / 2
        self.contentInset = UIEdgeInsets(top: newheight, left: 0, bottom: 0, right: 0)
        self.contentOffset = CGPoint(x: 0, y: -newheight)
        
        self.Setupnewview(headerView: headerView,
                          updateHeaderlayout: updateHeaderlayout,
                          headerHeight: headerHeight,
                          headerCut: headerCut)
    }
    
    func Setupnewview(headerView : UIView, updateHeaderlayout : CAShapeLayer, headerHeight : CGFloat, headerCut : CGFloat, headerStopAt : CGFloat=0){
        let newheight = headerHeight - headerCut / 2
        var headerframe = CGRect(x: 0, y: -newheight, width: self.bounds.width, height: headerHeight)
        if self.contentOffset.y < newheight
        {
            headerframe.origin.y = self.contentOffset.y
            headerframe.size.height = -self.contentOffset.y + headerCut / 2
        }
        
        if self.contentOffset.y > (-headerStopAt)
        {
            headerframe.origin.y = self.contentOffset.y
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

//extension UITableView {
//
//    func UpdateView(headerView : UIView, updateHeaderlayout : CAShapeLayer, headerHeight : CGFloat, headerCut : CGFloat) {
//        self.backgroundColor = UIColor.white
//        self.tableHeaderView = nil
//        self.rowHeight = UITableView.automaticDimension
//        self.addSubview(headerView)
//
//        updateHeaderlayout.fillColor = UIColor.black.cgColor
//        headerView.layer.mask = updateHeaderlayout
//
//        let newheight = headerHeight - headerCut / 2
//        self.contentInset = UIEdgeInsets(top: newheight, left: 0, bottom: 0, right: 0)
//        self.contentOffset = CGPoint(x: 0, y: -newheight)
//
//        self.Setupnewview(headerView: headerView,
//                          updateHeaderlayout: updateHeaderlayout,
//                          headerHeight: headerHeight,
//                          headerCut: headerCut)
//    }
//
//    func Setupnewview(headerView : UIView, updateHeaderlayout : CAShapeLayer, headerHeight : CGFloat, headerCut : CGFloat, headerStopAt : CGFloat=0){
//        let newheight = headerHeight - headerCut / 2
//        var headerframe = CGRect(x: 0, y: -newheight, width: self.bounds.width, height: headerHeight)
//        if self.contentOffset.y < newheight
//        {
//            headerframe.origin.y = self.contentOffset.y
//            headerframe.size.height = -self.contentOffset.y + headerCut / 2
//        }
//
//        if self.contentOffset.y > (-headerStopAt)
//        {
//            headerframe.origin.y = self.contentOffset.y
//            headerframe.size.height = headerStopAt
//        }
//
//
//        headerView.frame = headerframe
//        let cutdirection = UIBezierPath()
//        cutdirection.move(to: CGPoint(x: 0, y: 0))
//        cutdirection.addLine(to: CGPoint(x: headerframe.width, y: 0))
//        cutdirection.addLine(to: CGPoint(x: headerframe.width, y: headerframe.height))
//        cutdirection.addLine(to: CGPoint(x: 0, y: headerframe.height - headerCut))
//        updateHeaderlayout.path = cutdirection.cgPath
//    }
//}
