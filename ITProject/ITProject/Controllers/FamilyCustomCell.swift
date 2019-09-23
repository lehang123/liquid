//
//  FamilyCustomCell.swift
//  ITProject
//
//  Created by Gilbert Vincenta on 6/9/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit
class FamilyCustomCell: UITableViewCell {
    var position: String?
    var name: String?
    var role: String?

    var positionView: UITextView = {
        var textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
//        textView.isScrollEnabled = false
        textView.font = UIFont(name: "Thonburi", size: CGFloat(20.0))
        textView.backgroundColor = UIColor(red: 0, green: 255, blue: 255)

        return textView
    }()

    var nameView: UITextView = {
        var textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont(name: "Thonburi", size: CGFloat(20.0))
        textView.backgroundColor = UIColor(red: 0, green: 255, blue: 255)
//        textView.isScrollEnabled = false

        return textView
    }()

    var roleView: UITextView = {
        var textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont(name: "Thonburi", size: CGFloat(20.0))
        textView.backgroundColor = UIColor(red: 0, green: 255, blue: 255)
        //        textView.isScrollEnabled = false

        return textView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(red: 0, green: 255, blue: 255)

        addSubview(nameView)
        addSubview(positionView)
        // name - pos - role
//        nameView.leftAnchor.constraint(greaterThanOrEqualTo: self.leftAnchor , constant: CGFloat(0.5)).isActive = true
//        nameView.leftAnchor.constraint(greaterThanOrEqualTo: self.leftAnchor , constant: CGFloat(0.5)).isActive = true
        nameView.leftAnchor.constraint(equalTo: leftAnchor, constant: CGFloat(25.0)).isActive = true
//        nameView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        nameView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        nameView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        nameView.widthAnchor.constraint(equalTo: heightAnchor).isActive = true
        nameView.rightAnchor.constraint(equalTo: nameView.leftAnchor, constant: CGFloat(100.0)).isActive = true

        positionView.leftAnchor.constraint(lessThanOrEqualTo: nameView.rightAnchor, constant: CGFloat(50.0)).isActive = true
//        positionView.leftAnchor.constraint(equalTo: NSLayoutXAxisAnchor()).isActive = true
        positionView.rightAnchor.constraint(equalTo: positionView.leftAnchor, constant: CGFloat(100.0)).isActive = true
        positionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        positionView.topAnchor.constraint(equalTo: topAnchor).isActive = true

//        roleView.leftAnchor.constraint(equalTo: self.nameView.rightAnchor, constant: CGFloat(200)).isActive = true
//        roleView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
//        roleView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
//        roleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let position = position {
            positionView.text = position
        }
        if let name = name {
            nameView.text = name
        }
        if let role = role {
            roleView.text = role
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
