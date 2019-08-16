//
//  IndividualSettingViewContoller.swift
//  ITProject
//
//  Created by 陳信宏保佑🙏 on 2019/8/14.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit

class IndividualSettingViewController: UITableViewController {
    
    
//    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 55
//    }
//
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // refresh cell blur effect in case it changed
        tableView.reloadData()
    }
    
    
    
}

