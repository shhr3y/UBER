//
//  TripsCell.swift
//  UBER
//
//  Created by Shrey Gupta on 14/07/20.
//  Copyright © 2020 Shrey Gupta. All rights reserved.
//

import UIKit

import UIKit
import MapKit

class TripCell: UITableViewCell {

    //    MARK: - Properties
    let dateAndTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.text = "16:03 15 July, 2020"
        return label
    }()

    let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "Status: "
        return label
    }()
    
    let currentStatusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .systemYellow
        label.text = "ONGOING"
        return label
    }()

    private let locationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19)
        label.text = "Apple Business Park, Palo Alto, CA"
        return label
    }()
    
    let fareLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.text = "$0"
        return label
    }()
    
    private lazy var profileImageView: UIView = {
        let imageview = UIView()
        imageview.backgroundColor = .darkGray
        
        imageview.addSubview(initialLabel)
        initialLabel.centerX(inView: imageview)
        initialLabel.centerY(inView: imageview)
        
        return imageview
    }()
    
    private lazy var initialLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "A"
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    let driverFullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "Aakanksha Kelkar"
        return label
    }()
    
    //    MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        addSubview(dateAndTimeLabel)
        dateAndTimeLabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 20, paddingLeft: 15)
        
        let statusStack = UIStackView(arrangedSubviews: [statusLabel, currentStatusLabel])
        statusStack.axis = .horizontal
        statusStack.spacing = 1
        addSubview(statusStack)
        statusStack.anchor(right: rightAnchor, paddingRight: 15)
        statusStack.centerY(inView: dateAndTimeLabel)
        
        addSubview(locationIndicatorView)
        locationIndicatorView.anchor(top: dateAndTimeLabel.bottomAnchor, left: leftAnchor, paddingTop: 20, paddingLeft: 20)
        locationIndicatorView.setDimensions(height: 6, width: 6)
        
        addSubview(locationLabel)
        locationLabel.centerY(inView: locationIndicatorView)
        locationLabel.anchor(left: locationIndicatorView.rightAnchor, paddingLeft: 13)
        
        addSubview(fareLabel)
        fareLabel.anchor(left: leftAnchor, bottom: bottomAnchor, paddingLeft: 17, paddingBottom: 20)

        addSubview(driverFullnameLabel)
        driverFullnameLabel.centerY(inView: fareLabel)
        driverFullnameLabel.anchor(right: rightAnchor, paddingRight: 20)
        
        addSubview(profileImageView)
        profileImageView.anchor(right: driverFullnameLabel.leftAnchor, paddingRight: 5)
        profileImageView.centerY(inView: driverFullnameLabel)
        profileImageView.setDimensions(height: 40, width: 40)
        profileImageView.layer.cornerRadius = 40/2
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //    MARK: - Selectors
    
    
    //    MARK: - Helper Functions
}
