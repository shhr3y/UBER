//
//  HomeController.swift
//  UBER
//
//  Created by Shrey Gupta on 07/07/20.
//  Copyright © 2020 Shrey Gupta. All rights reserved.
//

import UIKit
import Firebase
import MapKit

private let reuseIdentifier = "LocationCell"
private let annotationIdentitfier = "AnnotationIdentifier"

class HomeController: UIViewController {
    //    MARK: - Properties
    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    
    private let inputActivationView: LocationInputActivationView = {
        return LocationInputActivationView()
    }()
    
    private let locationInputView: LocationInputView = {
        return LocationInputView()
    }()
    
    private var user: User? {
        didSet{
            locationInputView.user = user
        }
    }
    private final let locationInputViewHeight: CGFloat = 200
    
    private let tableView = UITableView()
    
    //    MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
//        signOut()
        enableLocationServices()
        
    }
    
    //    MARK: - Helper Functions
    func configureUI(){
        configureMapView()
        fetchUserData()
        fetchNearbyDrivers()
        
        view.addSubview(inputActivationView)
        inputActivationView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32, width: view.frame.width - 64, height: 50)
        inputActivationView.centerX(inView: view)
        inputActivationView.alpha = 0
        inputActivationView.delegate = self
        UIView.animate(withDuration: 1.5) {
            self.inputActivationView.alpha = 1
        }
        
        configureTableView()
    }
    
    func configureMapView(){
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        mapView.delegate = self
    }
    
    func configureLocationInputView(){
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor)
        locationInputView.centerX(inView: view)
        locationInputView.setDimensions(height: locationInputViewHeight, width: view.frame.width)
        locationInputView.alpha = 0
        
        locationInputView.delegate = self
        
        UIView.animate(withDuration: 0.5, animations: {
            self.locationInputView.alpha = 1
        }) { (isCompleted) in
            if(isCompleted){
                print("DEBUG: Present Table View")
                UIView.animate(withDuration: 0.3) {
                    self.tableView.frame.origin.y = self.locationInputViewHeight
                }
            }
        }
        
    }
    
    func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        
        tableView.tableFooterView = UIView()
        
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        
        view.addSubview(tableView)
    }
    
    //    MARK: - API
    
    func fetchUserData(){
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        Service.shared.fetchUserData(currentUID: currentUID) { (user) in
            self.user = user
            print("DEBUG: \(user.fullname) is logged in!")
        }
    }
    
    func fetchNearbyDrivers(){
        guard let location = locationManager?.location else { return }
        Service.shared.fetchDrivers(location: location) { (driver) in
            print("DEBUG: Driver's Name: \(driver.fullname)")
            guard let coordinate = driver.location?.coordinate else { return }
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            
            var driverIsVisibile: Bool {
                return self.mapView.annotations.contains { (annotation) -> Bool in
                    guard let driverAnno = annotation as? DriverAnnotation else { return false }
                    
                    if(driverAnno.uid == driver.uid){
                        driverAnno.updateAnnotationLocation(withCoordinate: coordinate)
                        return true
                    }
                    return false
                }
                
            }
            
            if !driverIsVisibile{
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    func checkIfUserIsLoggedIn(){
        if Auth.auth().currentUser?.uid == nil {
            print("DEBUG: User not logged in!")
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }else{
            configureUI()
            print("DEBUG: USER is logged in!")
            print("DEBUG: UID: \(Auth.auth().currentUser!.uid)")
        }
    }
    
    func signOut(){
        do{
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }catch{
            print("DEBUG: \(error)")
        }
    }
}


//    MARK: - Location Services
extension HomeController{
    func enableLocationServices(){
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("DEBUG: not determined")
            locationManager!.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .denied:
            break
        case .authorizedAlways:
            print("DEBUG: authorized always")
            locationManager!.startUpdatingLocation()
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: authorized when in use")
            locationManager!.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
}

//    MARK: - Extension LocationInputActivationViewDelegate

extension HomeController: LocationInputActivationViewDelegate{
    func presentLocationInputActivationView() {
        print("DEBUG: presentLocationInputActivationView called.")
        inputActivationView.alpha = 0
        configureLocationInputView()
        
    }
}

//    MARK: - Extension LocationInputViewDelegate

extension HomeController: LocationInputViewDelegate {
    func dismissLocationInputView() {
        print("DEBUG: dismissLocationInputView")
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
        }) { (_) in
            UIView.animate(withDuration: 0.1) {
                self.inputActivationView.alpha = 1
                self.locationInputView.removeFromSuperview()
            }
        }
    }
    
}

//    MARK: - Extension TableView Dalegate and DataSource
extension HomeController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Favorites" : "Recents"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        return cell
    }
}


//    MARK: - MapView Delegate

extension HomeController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentitfier)
            view.image = #imageLiteral(resourceName: "chevron-sign-to-right")
            return view
        }
        return nil
    }
}
