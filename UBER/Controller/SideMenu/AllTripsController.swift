//
//  AllTripsController.swift
//  UBER
//
//  Created by Shrey Gupta on 14/07/20.
//  Copyright © 2020 Shrey Gupta. All rights reserved.
//

import UIKit

private let resuseIdentifier = "TripCell"

class AllTripsController: UITableViewController {
    
    //    MARK: - Properties
    var user: User
    
    //    MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
//        print("DEBUG: prininting user from AllTripsController: \(user.previousTrip)")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .backgroundColor
        
        configureNavigationBar()
        configureTableView()
    }
    
    //    MARK: - Selectors
    @objc func handleBack(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //    MARK: - Helper Functions
    
    func configureTableView(){
        tableView.tableFooterView = UIView()
        
        tableView.rowHeight = 150
        tableView.register(TripCell.self, forCellReuseIdentifier: resuseIdentifier)
        tableView.backgroundColor = .white
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = "My Trips"
        
        
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

//    MARK: - Delegate TabelViewDelegate and DataSource

extension AllTripsController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: resuseIdentifier, for: indexPath) as! TripCell
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        present(nav, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

