//
//  MenuHeader.swift
//  UBER
//
//  Created by Shrey Gupta on 12/07/20.
//  Copyright © 2020 Shrey Gupta. All rights reserved.
//

import UIKit

class MenuHeader: UIView {
    //    MARK: - Properties
    private let user: User
    private var isEnabledPickup: Bool = true
    
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
        label.text = user.firstInitial
        label.font = UIFont.systemFont(ofSize: 30)
        return label
    }()
    
    private lazy var fullnameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = user.fullname
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.text = user.email
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()
    
    let pickupModeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(white: 1.0, alpha: 0.9)
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    lazy var pickupModeSwitch: UISwitch = {
        let s = UISwitch()
        s.isOn = true
        s.tintColor = .white
        s.onTintColor = .mainBlueTint
        s.addTarget(self, action: #selector(handlePickupModeChanged), for: .valueChanged)
        return s
    }()
    
    
    //    MARK: - Lifecycle
    init(user: User, frame: CGRect) {
        self.user = user
        super.init(frame: frame)
        print("DEBUG: lifecycle of MenuHeader")
        backgroundColor = . backgroundColor
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 4, paddingLeft: 12)
        profileImageView.setDimensions(height: 64, width: 64)
        profileImageView.layer.cornerRadius = 64/2
        
        
        let stack = UIStackView(arrangedSubviews: [fullnameLabel, emailLabel])
        stack.distribution = .fillEqually
        stack.spacing = 4
        stack.axis = .vertical
        
        addSubview(stack)
        stack.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, leftPadding: 12)
        
        configureSwitch()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //    MARK: - Selectors
    
    @objc func handlePickupModeChanged() {
        isEnabledPickup.toggle()
        changeStateOfPickupSwitch(to: isEnabledPickup)
    }
    
    //    MARK: - Helper Functions
    
    func configureSwitch() {
        if user.accountType == .driver {
            addSubview(pickupModeLabel)
            pickupModeLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 16)
            
            addSubview(pickupModeSwitch)
            pickupModeSwitch.anchor(top: pickupModeLabel.bottomAnchor, left: leftAnchor, paddingTop: 4, paddingLeft: 16)
            changeStateOfPickupSwitch(to: isEnabledPickup)
        }
    }
    
    func changeStateOfPickupSwitch(to state:Bool){
        pickupModeSwitch.isOn = state
        pickupModeLabel.text = state ? "PICKUP MODE ENABLED" : "PICKUP MODE DISABLED"
    }
}
