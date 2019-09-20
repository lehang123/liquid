//
//  FamilyTableController.swift
//  ITProject
//
//  Created by Gilbert Vincenta on 6/9/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit

struct CellData {
    let position : String?
    let name : String?
    let role : String?
}
class FamilyTableController: UITableViewController{
    private var data = [CellData]();

    override func viewDidLoad() {
        super.viewDidLoad()
        populateData()
        self.tableView.register(FamilyCustomCell.self, forCellReuseIdentifier: "custom")
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 400
    }
    
    
    func populateData(){
        
        data = [CellData.init(position: "position ", name : "name" , role  : "role" ),CellData.init(position: "wo jiu jiu ni ", name : "Ivan Wibowo", role  : "can edit" ), CellData.init(position: "wo jiu 22jiu ni ", name : "Maris Stella Angelita GUnadi", role  : "can delete"),CellData.init(position: "wo jiu jiu ni ", name : "Aurelia Griselda Wibowo", role  : "can view")]
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //no of rows required:
        print("DATA COUNT ::: \(data.count)")

        return data.count;
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "custom") as! FamilyCustomCell
        
        cell.position = data[indexPath.row].position
        cell.name = data[indexPath.row].name
        cell.role = data[indexPath.row].role
        print("RUMMMM")
        cell.layoutSubviews()
        return cell;
    }
}

