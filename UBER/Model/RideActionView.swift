//
//  RideActionView.swift
//  UBER
//
//  Created by Shrey Gupta on 08/07/20.
//  Copyright © 2020 Shrey Gupta. All rights reserved.
//

import UIKit
import MapKit

class RideActionView: UIView {
    
    var destination: MKPlacemark? {
        didSet{
            titleLabel.text = destination?.name
            addressLabel.text = destination?.address
        }
    }

    //    MARK: - Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "titleLabel"
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.text = "addressLabel"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        label.text = "X"
        
        view.addSubview(label)
        label.centerX(inView: view)
        label.centerY(inView: view)
        
        
        return view
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
        print("DEBUG: actionButtonPressed")
    }
    
    //    MARK: - Helper Functions
}
