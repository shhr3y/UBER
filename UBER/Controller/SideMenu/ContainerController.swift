//
//  ContainerController.swift
//  UBER
//
//  Created by Shrey Gupta on 12/07/20.
//  Copyright © 2020 Shrey Gupta. All rights reserved.
//

import UIKit
import Firebase

class ContainerController: UIViewController {
    
    //    MARK: - Properties
    
    private let homeController = HomeController()
    private var menuController: MenuController!
    private var isExpanded = false
    private let blackView = UIView()
    
    private var user: User? {
        didSet{
            guard let user = user else { return }
            configure(withUser: user)
        }
    }
    //    MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
    }
    
    override var prefersStatusBarHidden: Bool {
        return isExpanded
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    //    MARK: - Selectors
    @objc func dismissMenu(){
        isExpanded.toggle()
        animateMenu(shouldExpand: isExpanded)
    }
    
    //    MARK: - API Calls
    
    func checkIfUserIsLoggedIn(){
        print("DEBUG: CHECKING LOGIN STATUS")
        if Auth.auth().currentUser?.uid == nil {
            print("DEBUG: User not logged in!")
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }else{
            print("DEBUG: USER is logged in!  UID: \(Auth.auth().currentUser!.uid)")
            configureRootController()
        }
    }

    
    func fetchUserData(){
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        Service.shared.fetchUserData(currentUID: currentUID) { (user) in
            self.user = user
            print("DEBUG: \(user.fullname) is logged in!")
        }
    }
    
    func signOut(){
        do{
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.checkIfUserIsLoggedIn()
            }
        }catch{
            print("DEBUG: \(error)")
        }
    }
    
    //    MARK: - Helper Funcitons
    func configureRootController(){
        view.backgroundColor = .backgroundColor
        fetchUserData()
        configureHomeController()
    }
    
    func configure(withUser user: User){
        homeController.user = user
        homeController.reloadInputViews()
        configureMenuController(withUser: user)
    }
    
    func configureHomeController( ){
        homeController.delegate = self
        homeController.viewDidLoad()
        addChild(homeController)
        homeController.didMove(toParent: self)
        view.addSubview(homeController.view)
    }
    
    func configureMenuController(withUser user: User){
        menuController = MenuController(user: user)
        menuController.reloadInputViews()
        addChild(menuController)
        menuController.delegate = self
        menuController.didMove(toParent: self)
        view.insertSubview(menuController.view, at: 0)
        configureBlackView()
    }
    
    func configureBlackView(){
        blackView.frame = self.view.bounds
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        blackView.alpha = 0
        view.addSubview(blackView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        blackView.addGestureRecognizer(tap)
    }
    
    //    MARK: - Animating Menu Bar
    
    func animateMenu(shouldExpand: Bool, completion: ((Bool) -> Void)? = nil) {
        
        let xOrigin = self.view.frame.width - 80
        if shouldExpand {
            self.blackView.alpha = 1
            homeController.view.addSubview(blackView)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping:  0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.homeController.view.frame.origin.x = xOrigin
                
            }, completion: nil)
        }else{
            self.blackView.removeFromSuperview()
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping:  0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.homeController.view.frame.origin.x = 0
            }, completion: completion)
        }

    }
    
    func animateStatusBar() {
        UIView.animate(withDuration: 0.2, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
}


//    MARK: - Delegate SettingsControllerDelegate

extension ContainerController: SettingsControllerDelegate{
    func updateUser(_ controller: SettingsController) {
        self.user = controller.user
    }
}
//    MARK: - Delegate MenuControllerDelagate
extension ContainerController: MenuControllerDelegate {
    func didSelectOption(option: MenuOptions) {
        isExpanded.toggle()
        animateMenu(shouldExpand: isExpanded) { (_) in
            switch option {
            case .youTtrips:
                break
            case .settings:
                guard let user = self.user else { return }
                let controller = SettingsController(user: user)
                controller.delegate = self
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            case .logout:
                let alert = UIAlertController(title: nil, message: "Are you sure you want to logout?", preferredStyle: .actionSheet)
                
                alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { (_) in
                    self.signOut()
                    
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

//    MARK: - Delegate HomeControllerDelegate
extension ContainerController: HomeControllerDelegate{
    func handleMenuToggle() {
        isExpanded.toggle()
        animateMenu(shouldExpand: isExpanded)
    }
}
