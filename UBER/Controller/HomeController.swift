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

class HomeController: UIViewController {
    //    MARK: - Properties
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    
    private let inputActivationView: LocationInputActivationView = {
        return LocationInputActivationView()
    }()
    
    
    
    
    
    //    MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        enableLocationServices()
        
        inputActivationView.delegate = self
    }
    
    //    MARK: - Selectors
    
    
    
    
    
    //    MARK: - Helper Functions
    func configureUI(){
        configureMapView()
        
        view.addSubview(inputActivationView)
        inputActivationView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32, width: view.frame.width - 64, height: 50)
        inputActivationView.centerX(inView: view)
        inputActivationView.alpha = 0
        UIView.animate(withDuration: 2) {
            self.inputActivationView.alpha = 1
        }
    }
    
    func configureMapView(){
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    //    MARK: - API
    
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
            print("DEBUG: User is logged in!")
            print("DEBUG: UID: \(Auth.auth().currentUser!.uid)")
        }
    }
    
    func signOut(){
        do{
            try Auth.auth().signOut()
        }catch{
            print("DEBUG: \(error)")
        }
    }
}


//    MARK: - Location Services
extension HomeController: CLLocationManagerDelegate{
    func enableLocationServices(){
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("DEBUG: not determined")
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .denied:
            break
        case .authorizedAlways:
            print("DEBUG: authorized always")
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: authorized when in use")
            locationManager.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }
}

//    MARK: - Extensions

extension HomeController: LocationInputActivationViewDelegate{
    func presentLocationInputView() {
        print("DEBUG: 123")
    }
}
