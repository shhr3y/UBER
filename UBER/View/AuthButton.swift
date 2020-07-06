//
//  AuthButton.swift
//  UBER
//
//  Created by Shrey Gupta on 06/07/20.
//  Copyright © 2020 Shrey Gupta. All rights reserved.
//

import UIKit

class AuthButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .mainBlueTint
        layer.cornerRadius = 5
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
