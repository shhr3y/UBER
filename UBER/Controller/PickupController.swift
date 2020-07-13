//
//  PickupController.swift
//  UBER
//
//  Created by Shrey Gupta on 09/07/20.
//  Copyright © 2020 Shrey Gupta. All rights reserved.
//

import UIKit
import MapKit

protocol PickupControllerDelegate: class {
    func didAcceptTrip(trip: Trip)
}

class PickupController: UIViewController {
    //    MARK: - Properties
    
    weak var delegate: PickupControllerDelegate?
    let trip: Trip
    private let mapView = MKMapView()
    
    private lazy var circularProgressView: CircularProgressView = {
        let frame = CGRect(x: 0, y: 0, width: 360, height: 360)
        let cp = CircularProgressView(frame: frame)
        cp.addSubview(mapView)
        mapView.setDimensions(height: 268, width: 268)
        mapView.layer.cornerRadius =  268/2
        mapView.centerX(inView: cp)
        mapView.centerY(inView: cp, constant: 32)
        
        return cp
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDimissal), for: .touchUpInside)
        return button
    }()
    
    private let pickupLabel: UILabel = {
        let label = UILabel()
        label.text = "Would you like to pickup this passenger?"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    private let acceptTripButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("ACCEPT TITLE", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleAcceptTrip), for: .touchUpInside)
        return button
    }()
    
 
    
    
    //    MARK: - Lifecycle
    
    init(trip: Trip) {
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureMapView()
        self.perform(#selector(animateProgress), with: nil, afterDelay: 0.5)
    }
    
    //    MARK: - Selectors
    @objc func handleDimissal(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func animateProgress() {
        circularProgressView.animatePulsatingLayer()
        circularProgressView.setProgressWithAnimation(duration: 15, value: 0) {
            DriverService.shared.updateTripState(trip: self.trip, state: .isDenied) { (err, ref) in
                print("DEBUG: Denied is Called")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func handleAcceptTrip(){
        print("DEBUG: Ride Accepted")
        DriverService.shared.acceptTrip(trip: trip) { (error, reference) in
            self.delegate?.didAcceptTrip(trip: self.trip)
        }
    }
    
    //    MARK: - API
    
    //    MARK: - Helper Functions
    
    func configureUI(){
        view.backgroundColor = .backgroundColor
        
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,paddingTop: 14, paddingLeft: 16, width: 40, height: 40)
        
        
        //animation stuff
        view.addSubview(circularProgressView)
        circularProgressView.setDimensions(height: 360, width: 360)
        circularProgressView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        circularProgressView.centerX(inView: view)
        
        
//        view.addSubview(mapView)
//        mapView.setDimensions(height: 270, width: 270)
//        mapView.layer.cornerRadius = 270/2
//        mapView.centerX(inView: view)
//        mapView.centerY(inView: view, constant: -170)
        
        
        view.addSubview(pickupLabel)
        pickupLabel.centerX(inView: view)
        pickupLabel.anchor(top: circularProgressView.bottomAnchor, paddingTop: 32)
        
        view.addSubview(acceptTripButton)
        acceptTripButton.anchor(top: pickupLabel.bottomAnchor, paddingTop: 20)
        acceptTripButton.centerX(inView: view)
        acceptTripButton.setDimensions(height: 50, width: view.frame.width - 60)
        
    }
    
    func configureMapView(){
        let region = MKCoordinateRegion(center: trip.pickupCoordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: false)
        
        mapView.addAnnotationAndSelect(forCoordinates: trip.pickupCoordinates)
    }
    
}
