//
//  SettingsController.swift
//  UBER
//
//  Created by Shrey Gupta on 13/07/20.
//  Copyright © 2020 Shrey Gupta. All rights reserved.
//
import UIKit

private let resuseIdentifier = "LocationCell"

protocol SettingsControllerDelegate: class{
    func updateUser(_ controller: SettingsController)
}

enum LocationType: Int, CaseIterable, CustomStringConvertible {
    case home
    case work
    
    var description: String {
        switch self {
        case .home:
            return "Home"
        case .work:
            return "Work"
        }
    }
    
    var subtitle: String {
        switch self {
        case .home:
            return "Add Home"
        case .work:
            return "Add Work"
        }
    }
}

class SettingsController: UITableViewController {
    
    //    MARK: - Properties
    var user: User
    private let locationManager = LocationHandler.shared.locationManager
    weak var delegate: SettingsControllerDelegate?
    var userInfoUpdated = false
    
    private lazy var infoHeader: UserInfoHeader = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width , height: 100)
        let view = UserInfoHeader(user: user, frame: frame)
        return view
    }()
    
    //    MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        
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
        setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    //    MARK: - Selectors
    @objc func handleBack(){
        
        if userInfoUpdated {
            delegate?.updateUser(self)
            userInfoUpdated.toggle()
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    //    MARK: - Helper Functions
    
    func configureTableView(){
        tableView.tableHeaderView = infoHeader
        tableView.tableFooterView = UIView()
        
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
    
    func locationText(forType type: LocationType) -> String{
        switch type {
        case .home:
            return user.homeLocation ?? type.subtitle
        case .work:
            return user.workLocation ?? type.subtitle
        }
    }
    
}

//    MARK: - Delegate TabelViewDelegate and DataSource

extension SettingsController {

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .lightGray
        
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 16)
        title.textColor = .white
        title.text = "Favorites"
        
        view.addSubview(title)
        title.centerY(inView: view, leftAnchor: view.leftAnchor, leftPadding: 16)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationType.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: resuseIdentifier, for: indexPath) as! LocationCell
        
        guard let type = LocationType(rawValue: indexPath.row) else { return cell}
        cell.titleLabel.text = type.description
        cell.addressLabel.text = locationText(forType: type)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = LocationType(rawValue: indexPath.row) else { return }
        guard let location = locationManager?.location else { return }
        
        let controller = AddLocationController(type: type, location: location)
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        present(nav, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension SettingsController: AddLocationControllerDelegate {
    func updateLocation(locationString: String, type: LocationType) {
        PassengerService.shared.saveLocation(locationString: locationString, type: type) { (err,refernce) in
            self.dismiss(animated: true, completion: nil)
            self.userInfoUpdated = true
            
            switch type {
            case .home:
                self.user.homeLocation = locationString
            case .work:
                self.user.workLocation = locationString
            }
            
            self.tableView.reloadData()
        }
    }
}
