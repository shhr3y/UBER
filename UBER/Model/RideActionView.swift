//
//  RideActionView.swift
//  UBER
//
//  Created by Shrey Gupta on 08/07/20.
//  Copyright © 2020 Shrey Gupta. All rights reserved.
//

import UIKit
import MapKit

protocol RideActionViewDelegate: class {
    func uploadTrip(_ view: RideActionView)
    func cancelTrip()
    func pickupPassenger()
    func droppOffPassenger()
}

enum RideActionViewConfiguration {
    case requestRide
    case tripAccepted
    case pickupPassenger
    case driverArrived
    case tripInProgress
    case endTrip
    
    init() {
        self = .requestRide
    }
}

enum ButtonAction: CustomStringConvertible{
    case requestRide
    case cancel
    case getDirections
    case pickup
    case dropOff
    
    var description: String {
        switch self {
        case .requestRide: return "CONFIRM UBER X"
        case .cancel: return " CANCEL RIDE"
        case .getDirections: return "GET DIRECTIONS"
        case .pickup: return "PICKUP PASSENGER"
        case .dropOff: return "DROP OFF PASSENGER"
        }
    }
    
    init() {
        self = .requestRide
    }
}


class RideActionView: UIView {
    
    
    var destination: MKPlacemark? {
        didSet{
            titleLabel.text = destination?.name
            addressLabel.text = destination?.address
        }
    }
    
    var buttonAction = ButtonAction()
    weak var delegate: RideActionViewDelegate?
    var user: User?
    
    var config = RideActionViewConfiguration() {
        didSet{
            configureUI(withConfig: config)
        }
    }
    //    MARK: - Properties
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        
        view.addSubview(infoViewLabel)
        infoViewLabel.centerX(inView: view)
        infoViewLabel.centerY(inView: view)
        
        return view
    }()
    
    private let infoViewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        label.text = "X"
        
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Uber X "
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitle("CONFIRM UBER X", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    
    //    MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addShadow()
        
        let stack = UIStackView(arrangedSubviews: [titleLabel,addressLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        
        addSubview(stack)
        stack.centerX(inView: self)
        stack.anchor(top: topAnchor, paddingTop: 12)
        
        addSubview(infoView)
        infoView.layer.cornerRadius = 60/2
        infoView.setDimensions(height: 60, width: 60)
        infoView.anchor(top: stack.bottomAnchor, paddingTop: 16)
        infoView.centerX(inView: self)
        
        addSubview(infoLabel)
        infoLabel.anchor(top: infoView.bottomAnchor, paddingTop: 8)
        infoLabel.centerX(inView: self)
        
        addSubview(separatorView)
        separatorView.anchor(top: infoLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 4,paddingLeft: 20,paddingRight: 20, width: frame.width, height: 0.75)
        
        addSubview(actionButton)
        actionButton.anchor(top: separatorView.bottomAnchor,left: leftAnchor, right: rightAnchor,paddingTop: 20, paddingLeft: 30, paddingRight: 30, height: 50)
        actionButton.centerX(inView: self)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //    MARK: - Selector
    
    @objc func actionButtonPressed(){
        switch buttonAction {
        case .requestRide:
            delegate?.uploadTrip(self)
        case .cancel:
            delegate?.cancelTrip()
        case .getDirections:
            print("DEBUG: handleGetDirection")
        case .pickup:
            delegate?.pickupPassenger()
        case .dropOff:
            delegate?.droppOffPassenger()
        }
    }
    
    //    MARK: - Helper Functions
    
    private func configureUI(withConfig config: RideActionViewConfiguration){
        switch config {
        case .requestRide:
            buttonAction = .requestRide
            actionButton.setTitle(buttonAction.description, for: .normal)
        case .tripAccepted:
            guard let user = user else { return }
            
            if user.accountType == .passenger {
                titleLabel.text = "En Route to Passenger"
                buttonAction = .getDirections
                actionButton.setTitle(buttonAction.description, for: .normal )
            }else{
                buttonAction = .cancel
                actionButton.setTitle(buttonAction.description, for: .normal)
                titleLabel.text = "Driver is on your way!"
                addressLabel.text = ""
            }
            
            infoViewLabel.text = String(user.fullname.first ?? "X")
            infoLabel.text = user.fullname
        case .driverArrived:
            guard let user = user else { return }
            if user.accountType == .driver {
                titleLabel.text = "Driver has Arrived"
                addressLabel.text = "Please meet Driver at Pickup Location"
            }
            
        case .pickupPassenger:
            titleLabel.text = "Arrived at Passenger Location"
            buttonAction = .pickup
            actionButton.setTitle(buttonAction.description, for: .normal)
        case .tripInProgress:
            guard let user = user else { return }
            
            if user.accountType == .driver {
                actionButton.setTitle("TRIP IN PROGRESS", for: .normal)
                actionButton.isEnabled = false
            }else{
                buttonAction = .getDirections
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            titleLabel.text = "En Route to Destination"
        case .endTrip:
            guard let user = user else { return }
            
            if user.accountType == .driver {
                actionButton.setTitle("ARRIVED AT DESTINATION", for: .normal)
                actionButton.isEnabled = false
            }else{
                buttonAction = .dropOff
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            titleLabel.text = "Arrived at Destination"
        }
    }
}
