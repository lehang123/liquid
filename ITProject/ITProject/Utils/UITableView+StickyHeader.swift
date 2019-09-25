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
    /// update the header view
    /// - Parameters:
    ///   - headerView: header of a table view
    ///   - updateHeaderlayout: <#updateHeaderlayout description#>
    ///   - headerHeight: height for header
    ///   - headerCut: height for the cut appeared in the header
    func UpdateView(headerView: UIView, updateHeaderlayout: CAShapeLayer, headerHeight: CGFloat, headerCut: CGFloat) {
        backgroundColor = UIColor.white
        tableHeaderView = nil
        rowHeight = UITableView.automaticDimension

        frame = headerView.bounds
        addSubview(headerView)

        updateHeaderlayout.fillColor = UIColor.black.cgColor
        headerView.layer.mask = updateHeaderlayout

        let newheight = headerHeight - headerCut / 2
        contentInset = UIEdgeInsets(top: newheight, left: 0, bottom: 0, right: 0)
        contentOffset = CGPoint(x: 0, y: -newheight)

        Setupnewview(headerView: headerView,
                     updateHeaderlayout: updateHeaderlayout,
                     headerHeight: headerHeight,
                     headerCut: headerCut)
    }
    
    /// set up new header view
    /// - Parameter headerView: header of a table view
    /// - Parameter updateHeaderlayout: update header layout
    /// - Parameter headerHeight: height for header
    /// - Parameter headerCut: height for the cut appeadered in the header
    /// - Parameter headerStopAt: <#headerStopAt description#>
    func Setupnewview(headerView: UIView, updateHeaderlayout: CAShapeLayer, headerHeight: CGFloat, headerCut: CGFloat, headerStopAt: CGFloat = 0) {
        let newheight = headerHeight - headerCut / 2
        var headerframe = CGRect(x: 0, y: -newheight, width: bounds.width, height: headerHeight)
        if contentOffset.y < newheight {
            headerframe.origin.y = contentOffset.y
            headerframe.size.height = -contentOffset.y + headerCut / 2
        }

        if contentOffset.y > (-headerStopAt) {
            headerframe.origin.y = contentOffset.y
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
}
