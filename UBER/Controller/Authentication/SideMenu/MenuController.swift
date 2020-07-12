//
//  MenuControllerr.swift
//  UBER
//
//  Created by Shrey Gupta on 12/07/20.
//  Copyright © 2020 Shrey Gupta. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MenuCell"

class MenuController : UITableViewController {
    
    //    MARK: - Properties
    private lazy var menuHeader: MenuHeader = {
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 80, height: 140)
        let view = MenuHeader(frame: frame)
        
        return view
    }()
    
    //    MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
    }
    
    //    MARK: - Selectors
    
    
    //    MARK: - Helper Funcitons
    
    func configureTableView(){

        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.rowHeight = 60
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableHeaderView = menuHeader
    }
}


extension MenuController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = "kjhgfd"
        cell.textLabel?.textColor = .brown
        return cell
    }
    
}
