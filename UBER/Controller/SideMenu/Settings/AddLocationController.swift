//
//  AddLocationController.swift
//  UBER
//
//  Created by Shrey Gupta on 13/07/20.
//  Copyright © 2020 Shrey Gupta. All rights reserved.
//

import UIKit
import MapKit

private let reuseIdentifier = "cell"

protocol AddLocationControllerDelegate: class {
    func updateLocation(locationString: String, type: LocationType)
}

class AddLocationController: UITableViewController {
    //    MARK: - Properties
    weak var delegate: AddLocationControllerDelegate?
    
    private let searchBar: UISearchBar = {
        return UISearchBar()
    }()
    
    private let searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]() {
        didSet{
            tableView.reloadData()
        }
    }
    private let locationType: LocationType
    private let location: CLLocation
    //    MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureSearchBar()
        configureSearchCompleter()
    }
    
    init(type: LocationType, location: CLLocation) {
        self.locationType = type
        self.location = location
        
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //    MARK: - Selectors
    
    //    MARK: - Helper Functions
    
    func configureTableView(){
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 60
        
        tableView.addShadow()
    }
    
    func configureSearchBar(){
        searchBar.sizeToFit()
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        
        navigationItem.titleView = searchBar
    }
    
    func configureSearchCompleter() {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        searchCompleter.region = region
        searchCompleter.delegate = self
    }
}

//    MARK: - Delegate UISearchBarDelegate

extension AddLocationController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
}

//    MARK: - Delegate TableView DataSource/Delegate

extension AddLocationController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        let result = searchResults[indexPath.row]
        cell.textLabel?.text = result.title
        cell.detailTextLabel?.text = result.subtitle
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = searchResults[indexPath.row]
        let title = result.title
        let subTitle = result.subtitle
        
        let locationString = title + " " + subTitle
        
        delegate?.updateLocation(locationString: locationString, type: locationType)
    }
}

//    MARK: - Delegate SearchBarDelegate

extension AddLocationController: MKLocalSearchCompleterDelegate{
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
    }
}
