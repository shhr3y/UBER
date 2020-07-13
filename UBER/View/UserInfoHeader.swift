
//
//  UserInfoHeader.swift
//  UBER
//
//  Created by Shrey Gupta on 13/07/20.
//  Copyright © 2020 Shrey Gupta. All rights reserved.
//

import UIKit

class UserInfoHeader: UIView {
    
    //    MARK: - Properties
    private let user: User
    
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
    
    
    //    MARK: - Lifecycle
    init(user: User, frame: CGRect) {
        self.user = user
        super.init(frame: frame)
        print("DEBUG: lifecycle of MenuHeader")
        backgroundColor = . backgroundColor
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 18, paddingLeft: 12)
        profileImageView.setDimensions(height: 64, width: 64)
        profileImageView.layer.cornerRadius = 64/2
        
        let stack = UIStackView(arrangedSubviews: [fullnameLabel, emailLabel])
        stack.distribution = .fillEqually
        stack.spacing = 4
        stack.axis = .vertical
        
        addSubview(stack)
        stack.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, leftPadding: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //    MARK: - Selectors
    
}
