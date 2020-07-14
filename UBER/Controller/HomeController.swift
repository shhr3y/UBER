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

private enum AnnotationType: String {
    case pickup
    case destination
}

protocol HomeControllerDelegate: class {
    func handleMenuToggle()
}


class HomeController: UIViewController {
    //    MARK: - Properties
    weak var delegate: HomeControllerDelegate?
    
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private let rideActionView = RideActionView()
    private let tableView = UITableView()
    private let mapView = MKMapView()
    private var savedLocations = [MKPlacemark]()
    private var searchResults = [MKPlacemark]()
    private let locationManager = LocationHandler.shared.locationManager
    private var actionButtonConfig = ActionButtonConfiguration()
    private var route: MKRoute?
    private final let locationInputViewHeight: CGFloat = 200
    private final let rideActionViewHeight: CGFloat = 300
    
    var user: User? {
        didSet{
            locationInputView.user = user
            if user?.accountType == .passenger {
                fetchNearbyDrivers()
                configureInputActivationView()
                observeCurrentTrip()
                configureSavedUserLocations()
            }else{
                print("DEBUG: User is Driver.")
                observeTrips()
            }
        }
    }
    
    private var trip: Trip? {
        didSet{
            guard let user = user else { return }
            
            if user.accountType == .driver {
                guard let trip = trip else { return }
                let controller = PickupController(trip: trip)
                controller.delegate = self
                present(controller, animated: true, completion: nil)
            }else{
                print("DEBUG: Show RideAcceptedView!")

            }
        }
    }
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
        
    //    MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableLocationServices()
        configure()
    }
    //    MARK: - Selectors
    
    @objc func actionButtonPressed(){
        switch actionButtonConfig {
        case .dismissActionView:
            removeAnnotaionsAndOverlays()
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
                self.configureActionButton(config: .showMenu)
                self.animateRideActionView(shouldShow: false)
            }
            
            mapView.showAnnotations(mapView.annotations, animated: true)
        case .showMenu:
            delegate?.handleMenuToggle()
            
        }
    }
    
    //    MARK: - Helper Functions
    
    func configure(){
        print("DEBUG: configuring UI")
        configureMapView()
        configureUI()
    }
    
    func configureUI(){
        
        configureRideActionView()
        
        view.addSubview(actionButton)
        actionButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 0, paddingLeft: 25.5)
        actionButton.setDimensions(height: 30, width: 30)
        
        configureTableView()
    }
    
    func configureInputActivationView(){
        view.addSubview(inputActivationView)
        inputActivationView.anchor(top: actionButton.bottomAnchor, paddingTop: 27, width: view.frame.width - 64, height: 50)
        inputActivationView.centerX(inView: view)
        inputActivationView.alpha = 0
        inputActivationView.delegate = self
        UIView.animate(withDuration: 1) {
            self.inputActivationView.alpha = 1
        }
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
    
    func configureSavedUserLocations(){
        guard let user = user else { return }
        savedLocations.removeAll()
        
        if let homeLocation = user.homeLocation {
            geocodeAddressString(address: homeLocation)
        }
        if let workLocation = user.workLocation {
            geocodeAddressString(address: workLocation)
        }
    }
    
    func geocodeAddressString(address: String){
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            guard let clPlacmark = placemarks?.first else { return }
            let placemark = MKPlacemark(placemark: clPlacmark)
            self.savedLocations.append(placemark)
            self.tableView.reloadData()
        }
    }
    
    func configureRideActionView(){
        rideActionView.delegate = self
        view.addSubview(rideActionView)
        rideActionView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: rideActionViewHeight)
    }
    
    func animateRideActionView(shouldShow: Bool, destination: MKPlacemark? = nil, config: RideActionViewConfiguration? = nil, user: User? = nil) {
        let yOrigin = shouldShow ? (self.view.frame.height - self.rideActionViewHeight) : self.view.frame.height
        
        UIView.animate(withDuration: 0.3) {
            self.rideActionView.frame.origin.y = yOrigin
        }

        if shouldShow {
            guard let config = config else { return }

            if let destination = destination {
                rideActionView.destination = destination
            }
            if let user = user {
                rideActionView.user = user
            }

            rideActionView.config = config
        }
    }

    
    //    MARK: - Passenger API Calls
    
    func fetchNearbyDrivers(){
        guard let location = locationManager?.location else { return }
        PassengerService.shared.fetchDrivers(location: location) { (driver) in
            print("DEBUG: Nearby Driver's Name: \(driver.fullname)")
            guard let coordinate = driver.location?.coordinate else { return }
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            
            var driverIsVisibile: Bool {
                return self.mapView.annotations.contains { (annotation) -> Bool in
                    guard let driverAnno = annotation as? DriverAnnotation else { return false }
                    
                    if(driverAnno.uid == driver.uid){
                        driverAnno.updateAnnotationLocation(withCoordinate: coordinate)
                        self.zoomForActiveTrip(withDriverUID: driver.uid)
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
    
    func observeCurrentTrip() {
        PassengerService.shared.obeseveCurrentTrip { (trip) in
            self.trip = trip
            
            guard let driverUID = trip.driverUID else { return }
            guard let state = trip.state else { return }
            
            switch state {
            case .isRequested:
                break
            case .isDenied:
                self.shouldPresentLoadingView(false)
                print("DEBUG: IS DENIED CASE CALLED")
                PassengerService.shared.deleteTrip { (err, ref) in
                    self.presentAlertController(withTitle: "Oops!", withMessage: "Sorry, It looks like we couldnt find you a driver. Please try again..")
                    self.centerMapOnUserLocation()
                    self.configureActionButton(config: .showMenu)
                    self.inputActivationView.alpha = 1
                    self.removeAnnotaionsAndOverlays()
                } 
            case .isAccepted:
                print("DEBUG: Trip was Accepted")
                self.shouldPresentLoadingView(false)
                self.removeAnnotaionsAndOverlays()
                
                self.zoomForActiveTrip(withDriverUID: driverUID)
                
                Service.shared.fetchUserData(currentUID: driverUID) { (driver) in
                    self.animateRideActionView(shouldShow: true, config: .tripAccepted, user: driver)
                }
            case .driverArrived:
                self.rideActionView.config = .driverArrived
            case .inProgress:
                self.rideActionView.config = .tripInProgress
            case .arrivedAtDestination:
                self.rideActionView.config = .endTrip
            case .isCompleted:
                PassengerService.shared.deleteTrip { (error, reference) in
                    self.animateRideActionView(shouldShow: false)
                    self.centerMapOnUserLocation()
                    self.configureActionButton(config: .showMenu)
                    self.inputActivationView.alpha = 1
                    self.presentAlertController(withTitle: "Trip Completed", withMessage: "We hope you enjoyed your trip with \(driverUID)")
                }
            }
        }
    }
    
    func startTrip(){
        guard let trip = self.trip else { return }
        DriverService.shared.updateTripState(trip: trip, state: .inProgress) { (error, reference) in
            self.rideActionView.config = .tripInProgress
            self.removeAnnotaionsAndOverlays()
            self.mapView.addAnnotationAndSelect(forCoordinates: trip.destinationCoordinates)
            
            self.setCustomRegion(withType: .destination, coordinates: trip.destinationCoordinates )
            
            let placemark = MKPlacemark(coordinate: trip.destinationCoordinates)
            let mapItem = MKMapItem(placemark: placemark)
            self.generatePolyline(toDestination: mapItem)
            
            self.mapView.zoomToFit(annotations: self.mapView.annotations)
        }
    }
    
    //    MARK: - Driver API Calls
    
    func observeTrips(){
        DriverService.shared.observeTrips { (trip) in
            self.trip = trip
        }
    }
    
    func observeCancelledTrip(forTrip trip: Trip){
        DriverService.shared.observeTripCancelled(trip: trip) {
            self.removeAnnotaionsAndOverlays()
            self.animateRideActionView(shouldShow: false)
            self.centerMapOnUserLocation()
            self.presentAlertController(withTitle: "Oops!", withMessage: "This Trip was cancelled by the Passenger.")
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
    
    func removeAnnotaionsAndOverlays() {
        self.mapView.annotations.forEach { (annotation) in
            if let anno = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(anno)
            }
        }
        
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
    }
    
    func centerMapOnUserLocation(){
        guard let coordinate = locationManager?.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        
        mapView.setRegion(region, animated: true)
    }
    
    func setCustomRegion(withType type: AnnotationType, coordinates:CLLocationCoordinate2D){
        
        let circularRegion = CLCircularRegion(center: coordinates, radius: 40, identifier: type.rawValue)
        locationManager?.startMonitoring(for: circularRegion)
    }
    
    func zoomForActiveTrip(withDriverUID uid: String){
        var onMapAnnotations = [MKAnnotation]()
        
        self.mapView.annotations.forEach({ (annotation) in
            if let anno = annotation as? DriverAnnotation {
                if anno.uid == uid {
                    onMapAnnotations.append(anno)
                }
            }
            
            if let userAnno = annotation as? MKUserLocation {
                onMapAnnotations.append(userAnno)
            }
        })
        
        self.mapView.zoomToFit(annotations: onMapAnnotations)

    }
}



//    MARK: - Delegate LocationaManagerDelegare & Location Services
extension HomeController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        if region.identifier == AnnotationType.pickup.rawValue {
            print("DEBUG: Did start Monitering pickup region: \(region)")
        }
        if region.identifier == AnnotationType.destination.rawValue {
            print("DEBUG: Did start Monitering detination region: \(region)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("DEBUG: Did Enter Circular Region")
        guard let trip = self.trip else { return }
        
        if region.identifier == AnnotationType.pickup.rawValue {
            print("DEBUG: Did start Monitering pickup region: \(region)")
            DriverService.shared.updateTripState(trip: trip, state: .driverArrived) { (error, reference) in
                self.rideActionView.config = .pickupPassenger
            }
        }
        if region.identifier == AnnotationType.destination.rawValue {
            print("DEBUG: Did start Monitering detination region: \(region)")
            DriverService.shared.updateTripState(trip: trip, state: .arrivedAtDestination) { (error, reference) in
                self.rideActionView.config = .endTrip
            }
        }
        
    }
    
    func enableLocationServices(){
        
        locationManager?.delegate = self
        
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

//    MARK: - Delegate LocationInputActivationViewDelegate

extension HomeController: LocationInputActivationViewDelegate{
    func presentLocationInputActivationView() {
        print("DEBUG: presentLocationInputActivationView called.")
        inputActivationView.alpha = 0
        configureLocationInputView()
        
    }
}

//    MARK: - Delegate LocationInputViewDelegate

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

//    MARK: - Delegate TableView Dalegate and DataSource

extension HomeController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Favorites" : "Results"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? savedLocations.count : searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        
        if indexPath.section == 0 {
            cell.placemark = savedLocations[indexPath.row]
        }
        if indexPath.section == 1 {
            cell.placemark = searchResults[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlacemark = indexPath.section == 0 ? savedLocations[indexPath.row] : searchResults[indexPath.row]
        configureActionButton(config: .dismissActionView)
        
        let destination = MKMapItem(placemark: selectedPlacemark)
        generatePolyline(toDestination: destination)
        
        dismissLocationView { (_) in
            self.mapView.addAnnotationAndSelect(forCoordinates: selectedPlacemark.coordinate)
        
            let annotations = self.mapView.annotations.filter({ !$0.isKind(of: DriverAnnotation.self)})
            self.mapView.zoomToFit(annotations: annotations)
            
            self.mapView.showAnnotations(annotations, animated: true)
            
            self.animateRideActionView(shouldShow: true, destination: selectedPlacemark, config: .requestRide)
        }
    }
}

//    MARK: - Delegate RideActionViewDelegate

extension HomeController: RideActionViewDelegate{
    func cancelTrip() {
        print("DEBUG: cancelTrip called")
        PassengerService.shared.deleteTrip { (error, reference) in
            if let error = error {
                print("DEBUG: Error Cancelling Ride: \(error.localizedDescription)")
                return
            }
            self.animateRideActionView(shouldShow: false)
            self.removeAnnotaionsAndOverlays()
            self.centerMapOnUserLocation()
            
            self.actionButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfig = .showMenu
            
            self.inputActivationView.alpha = 1
        }
    }
    
    func uploadTrip(_ view: RideActionView) {
        
        guard let pickupCoordinates = locationManager?.location?.coordinate else { return }
        guard let destinationCoordinates = view.destination?.coordinate else { return }
        
        shouldPresentLoadingView(true, message: "Finding you a ride...")
        
        PassengerService.shared.uploadTrip(from: pickupCoordinates, to: destinationCoordinates) { (error, reference) in
            if let error = error {
                print("DEBUG: Failed to upload Trip to Database with Error: \(error.localizedDescription) ")
                return
            }
            UIView.animate(withDuration: 0.3) {
                self.rideActionView.frame.origin.y = self.view.frame.height
            }
            print("DEBUG: Successfully Added your Trip.")
        }
    }
    
    func pickupPassenger() {
        startTrip()
    }
    
    func droppOffPassenger() {
        guard let trip = self.trip else { return }
        
        DriverService.shared.updateTripState(trip: trip, state: .isCompleted) { (error, reference) in
            self.removeAnnotaionsAndOverlays()
            self.centerMapOnUserLocation()
            self.animateRideActionView(shouldShow: false)
        }
    }
    
}

//    MARK: - Delegate PickupViewController

extension HomeController: PickupControllerDelegate{
    func didAcceptTrip(trip: Trip) {
        self.trip = trip
        
        self.mapView.addAnnotationAndSelect(forCoordinates: trip.pickupCoordinates)
        
        setCustomRegion(withType: .pickup, coordinates: trip.pickupCoordinates)
        
        let placmark = MKPlacemark(coordinate: trip.pickupCoordinates)
        let mapItem = MKMapItem(placemark: placmark)
        generatePolyline(toDestination: mapItem)
        
        mapView.zoomToFit(annotations: mapView.annotations)
        
        observeCancelledTrip(forTrip: trip)
        
        self.dismiss(animated: true) {
            Service.shared.fetchUserData(currentUID: trip.passengerUID) { (passenger) in
                self.animateRideActionView(shouldShow: true, config: .tripAccepted, user: passenger)
            }
        }
    }
}

//    MARK: Delegate MapView

extension HomeController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let user = self.user else { return }
        guard user.accountType == .driver else { return }
        
        guard let location = userLocation.location else { return }
        PassengerService.shared.updateDriverLocation(location: location)
    }
    
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
