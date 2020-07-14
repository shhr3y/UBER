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
    private var tripaccepted = false
    
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
    
    private lazy var passengerFullnameLabel: UILabel = {
        let label = UILabel()
        label.text = trip.passengerFullname
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = trip.destinationTitleLabel
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = .white
        return label
    }()
    
    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.text = trip.destinationAddressLabel
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        return label
    }()
    
    private let acceptTripButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("ACCEPT TRIP", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleAcceptTrip), for: .touchUpInside)
        return button
    }()
    
 
    
    
    //    MARK: - Lifecycle
    
    init(trip: Trip) {
        self.trip = trip
        print("DEBUG: FROM PICKUPCONTROLLER: \(trip)")
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
    
    @objc func handleAcceptTrip(){
        print("DEBUG: Ride Accepted")
        tripaccepted = true
        DriverService.shared.acceptTrip(trip: trip) { (error, reference) in
            self.delegate?.didAcceptTrip(trip: self.trip)
        }
    }
    @objc func animateProgress() {
        circularProgressView.animatePulsatingLayer()
        circularProgressView.setProgressWithAnimation(duration: 15, value: 0) {
            self.controlProgress()
        }
    }
    
    @objc func controlProgress(){
        if tripaccepted {
            self.dismiss(animated: true, completion: nil)
        }
        else {
//            DriverService.shared.updateTripState(trip: self.trip, state: .isDenied) { (err, ref) in
//                self.dismiss(animated: true, completion: nil)
//            }
        }
    }
    
    @objc func handleDimissal(){
//        DriverService.shared.updateTripState(trip: self.trip, state: .isDenied) { (err, ref) in
//            self.dismiss(animated: true, completion: nil)
//        }
    }
    
    //    MARK: - API
    
    //    MARK: - Helper Functions
    
    func configureUI(){
        view.backgroundColor = .backgroundColor
        
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,paddingTop: 14, paddingLeft: 16, width: 40, height: 40)
        
        view.addSubview(passengerFullnameLabel)
        passengerFullnameLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        passengerFullnameLabel.centerY(inView: cancelButton)
        passengerFullnameLabel.centerX(inView: view)
        
        view.addSubview(circularProgressView)
        circularProgressView.setDimensions(height: 360, width: 360)
        circularProgressView.anchor(top: passengerFullnameLabel.topAnchor, paddingTop: 10)
        circularProgressView.centerX(inView: view)
        
        view.addSubview(titleLabel)
        titleLabel.anchor(top: circularProgressView.bottomAnchor, paddingTop: 20)
        titleLabel.centerX(inView: view)
        
        view.addSubview(addressLabel)
        addressLabel.anchor(top: titleLabel.bottomAnchor, paddingTop: 5)
        addressLabel.centerX(inView: view)
        
        view.addSubview(acceptTripButton)
        acceptTripButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 40)
        acceptTripButton.centerX(inView: view)
        acceptTripButton.setDimensions(height: 50, width: view.frame.width - 60)
        
        view.addSubview(pickupLabel)
        pickupLabel.centerX(inView: view)
        pickupLabel.anchor(bottom: acceptTripButton.topAnchor, paddingBottom: 20)
    }
    
    func configureMapView(){
        let region = MKCoordinateRegion(center: trip.pickupCoordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: false)
        
        mapView.addAnnotationAndSelect(forCoordinates: trip.pickupCoordinates)
    }
    
}
