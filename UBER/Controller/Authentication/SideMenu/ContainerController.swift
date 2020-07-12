//
//  ContainerController.swift
//  UBER
//
//  Created by Shrey Gupta on 12/07/20.
//  Copyright © 2020 Shrey Gupta. All rights reserved.
//

import UIKit

class ContainerController: UIViewController {
    
    //    MARK: - Properties
    
    private let homeController = HomeController()
    private let menuController = MenuController()
    private var isExpanded = false
    //    MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundColor
        
        configureHomeController()
        configureMenuController()
    }
    
    //    MARK: - Selectors
    
    
    //    MARK: - Helper Funcitons
    
    func configureHomeController(){
        homeController.delegate = self
        
        addChild(homeController)
        
        homeController.didMove(toParent: self)
        view.addSubview(homeController.view)
    }
    
    func configureMenuController(){
        addChild(homeController)
        
        homeController.didMove(toParent: self)
        view.insertSubview(menuController.view, at: 0)
    }
    
    func animateMenu(shouldExpand: Bool) {
        if shouldExpand {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping:  0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.homeController.view.frame.origin.x = self.view.frame.width - 80
            }, completion: nil)
        }else{
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping:  0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.homeController.view.frame.origin.x = 0
            }, completion: nil)
        }
        animateStatusBar()
    }
    
    func animateStatusBar() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
}


extension ContainerController: HomeControllerDelegate{
    func handleMenuToggle() {
        isExpanded.toggle()
        animateMenu(shouldExpand: isExpanded)
    }
}
