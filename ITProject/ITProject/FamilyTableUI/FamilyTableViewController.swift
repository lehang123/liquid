//
//  FamilyTableController.swift
//  ITProject
//
//  Created by Gilbert Vincenta on 6/9/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import EnhancedCircleImageView
import Foundation
import UIKit

struct FamilyMember: Equatable
{
	static func == (lhs: FamilyMember, rhs: FamilyMember) -> Bool
	{
		return lhs.UID == rhs.UID
	}

	let UID: String!
	let phone: String?
	let name: String?
	let relationship: String?
}

class FamilyTableViewController: UITableViewController
{
	//    private var data = [CellData]();

	private let dummyFamilyMembers = [FamilyMember(UID: Util.GenerateUDID(), phone: "18006123153", name: "Darth Vader", relationship: "Father"),
	                                  FamilyMember(UID: Util.GenerateUDID(), phone: "2312312", name: "Luke Sky Walker", relationship: "Son")]

	private var familyMembers = [FamilyMember]()

	private var headerView: UIView!
	private var updateHeaderlayout: CAShapeLayer!

	@IBOutlet var familyPhoto: UIImageView!

	private let headerHeight: CGFloat = UIScreen.main.bounds.height * 0.4
	private let headerCut: CGFloat = 0
	private static let HEADER_MIN_HEIGHT = UIScreen.main.bounds.height * 0.2

	private static let INFO_DESCRIB_CELL = "InfoDescriCell"
	private static let FAMILY_MEMEBER_CELL = "FamilyMemberCell"
	private static let INTRODUCTION_ROW = 1

	override func viewDidLoad()
	{
		super.viewDidLoad()

		self.familyMembers = self.dummyFamilyMembers

		self.headerView = self.tableView.tableHeaderView
		self.updateHeaderlayout = CAShapeLayer()
		self.tableView.UpdateView(headerView: self.headerView, updateHeaderlayout: self.updateHeaderlayout, headerHeight: self.headerHeight, headerCut: self.headerCut)

		//        populateData()
		//        self.tableView.register(FamilyCustomCell.self, forCellReuseIdentifier: "custom")
		//        self.tableView.rowHeight = UITableView.automaticDimension
		//        self.tableView.estimatedRowHeight = 400
	}

	override func scrollViewDidScroll(_: UIScrollView)
	{
		self.tableView.Setupnewview(headerView: self.headerView, updateHeaderlayout: self.updateHeaderlayout, headerHeight: self.headerHeight, headerCut: self.headerCut, headerStopAt: CGFloat(FamilyTableViewController.HEADER_MIN_HEIGHT))
	}

	override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int
	{
		return self.familyMembers.count + FamilyTableViewController.INTRODUCTION_ROW
	}

	override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		if indexPath.row == 0 {
			let cell = self.tableView.dequeueReusableCell(withIdentifier: FamilyTableViewController.INFO_DESCRIB_CELL)

			return cell!
		}
		else
		{
			let cell = self.tableView.dequeueReusableCell(withIdentifier: FamilyTableViewController.FAMILY_MEMEBER_CELL) as! FamilyTableViewMemberCell
			cell.nameLabel.text = self.familyMembers[indexPath.row - 1].name
			cell.relationshipLabel.text = self.familyMembers[indexPath.row - 1].relationship
			cell.phoneLabel.text = self.familyMembers[indexPath.row - 1].phone

			return cell
		}
	}
}
