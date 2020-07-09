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
private enum ActionButtonConfiguration {
    case showMenu
    case dismissActionView
    
    init() {
        self = .showMenu
    }
}


class HomeController: UIViewController {
    //    MARK: - Properties
    private let mapView = MKMapView()
    private var searchResults = [MKPlacemark]()
    private let locationManager = LocationHandler.shared.locationManager
    private var actionButtonConfig = ActionButtonConfiguration()
    private var route: MKRoute?
    
    
    private let inputActivationView: LocationInputActivationView = {
        return LocationInputActivationView()
    }()
    private let locationInputView: LocationInputView = {
        return LocationInputView()
    }()
    private let rideActionView: RideActionView = {
        return RideActionView()
    }()
    
    private var user: User? {
        didSet{
            locationInputView.user = user
        }
    }
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    private final let locationInputViewHeight: CGFloat = 200
    private final let rideActionViewHeight: CGFloat = 300
    
    private let tableView = UITableView()
    
    //    MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
//        signOut()
        enableLocationServices()

    }
    
    //    MARK: - Selectors
    
    @objc func actionButtonPressed(){
        switch actionButtonConfig {
        case .dismissActionView:
            removeAnnotaionsAndoverlay()
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
                self.configureActionButton(config: .showMenu)
                self.animateRideActionView(shouldShow: false)
            }
            
            mapView.showAnnotations(mapView.annotations, animated: true)
        case .showMenu:
            print("DEBUG: Handle showMenu")
//            signOut()
            break
        }
    }
    
    //    MARK: - Helper Functions
    
    func configure(){
        print("DEBUG: configuring UI")
        configureMapView()
        configureUI()
        fetchUserData()
        fetchNearbyDrivers()
    }
    
    func configureUI(){
        
        configureRideActionView()
        
        view.addSubview(actionButton)
        actionButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 0, paddingLeft: 25.5)
        actionButton.setDimensions(height: 30, width: 30)
        
        view.addSubview(inputActivationView)
        inputActivationView.anchor(top: actionButton.bottomAnchor, paddingTop: 27, width: view.frame.width - 64, height: 50)
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
    
    func dismissLocationView(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.tableView.frame.origin.y = self.view.frame.height
            self.locationInputView.removeFromSuperview()
        }, completion: completion)
    }
    
    fileprivate func configureActionButton(config: ActionButtonConfiguration){
        switch config {
        case .showMenu:
            self.actionButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfig = .showMenu
        case .dismissActionView:
            actionButton.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            actionButtonConfig = .dismissActionView
        }
    }
    
    func configureRideActionView(){
        view.addSubview(rideActionView)
        rideActionView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: rideActionViewHeight)
    }
    
    func animateRideActionView(shouldShow: Bool, destination: MKPlacemark? = nil) {
        
        if shouldShow {
            guard let destination = destination else { return }
            rideActionView.destination = destination
        }
        
        let yOrigin = shouldShow ? (self.view.frame.height - self.rideActionViewHeight) : self.view.frame.height
        
        UIView.animate(withDuration: 0.3) {
            self.rideActionView.frame.origin.y = yOrigin
        }
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
            configure()
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



//    MARK: - MapView Helper Functions

private extension HomeController {
    func searchBy(naturalLanguageQuery: String, completion: @escaping([MKPlacemark]) -> Void){
        var results = [MKPlacemark]()
        
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else { return }
            response.mapItems.forEach({ (item) in
                results.append(item.placemark)
            })
            completion(results)
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
    
    func generatePolyline(toDestination destination: MKMapItem){
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { (response, error) in
            guard let response = response else { return }
            self.route = response.routes[0]
            guard let polyLine = self.route?.polyline else { return }
            self.mapView.addOverlay(polyLine)
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
    func executeSearch(query: String) {
        searchBy(naturalLanguageQuery: query) { (results) in
            self.searchResults = results
            self.tableView.reloadData()
        }
    }
    
    func dismissLocationInputView() {
        dismissLocationView { (_) in
            UIView.animate(withDuration: 0.5) {
                self.inputActivationView.alpha = 1
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
        return section == 0 ? 2 : searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        if indexPath.section == 1 {
            cell.placemark = searchResults[indexPath.row]
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlacamark = searchResults[indexPath.row]
        
        
        configureActionButton(config: .dismissActionView)
        
        let destination = MKMapItem(placemark: selectedPlacamark)
        generatePolyline(toDestination: destination)
        
        dismissLocationView { (_) in
            let annotation = MKPointAnnotation()
            annotation.coordinate = selectedPlacamark.coordinate
            annotation.title = selectedPlacamark.name
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)
            
            let annotations = self.mapView.annotations.filter({ !$0.isKind(of: DriverAnnotation.self)})
            
            self.mapView.showAnnotations(annotations, animated: true)
            
            self.animateRideActionView(shouldShow: true, destination: selectedPlacamark)
        }
    }
    
    func removeAnnotaionsAndoverlay() {
        self.mapView.annotations.forEach { (annotation) in
            if let anno = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(anno)
            }
        }
        
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
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
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(polyline: polyline)
            lineRenderer.strokeColor = .black
            lineRenderer.lineWidth = 3
            return lineRenderer
        }
        return MKOverlayRenderer()
    }
}
