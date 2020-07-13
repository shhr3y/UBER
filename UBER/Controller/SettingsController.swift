//
//  SettingsController.swift
//  UBER
//
//  Created by Shrey Gupta on 13/07/20.
//  Copyright © 2020 Shrey Gupta. All rights reserved.
//
import UIKit

private let resuseIdentifier = "LocationCell"

class SettingsController: UITableViewController {
    
    //    MARK: - Properties
    
    
    //    MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureTableView()
        setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    //    MARK: - Selectors
    @objc func handleBack(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //    MARK: - Helper Functions
    
    func configureTableView(){
        tableView.rowHeight = 60
        tableView.register(LocationCell.self, forCellReuseIdentifier: resuseIdentifier)
        tableView.backgroundColor = .white
        
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = "Settings"
        
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .backgroundColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleBack))
    }
    
}
