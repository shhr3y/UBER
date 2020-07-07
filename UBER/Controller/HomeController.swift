//
//  HomeController.swift
//  UBER
//
//  Created by Shrey Gupta on 07/07/20.
//  Copyright © 2020 Shrey Gupta. All rights reserved.
//

import UIKit
import Firebase

class HomeController: UIViewController {
    //    MARK: - Properties
    
    
    //    MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
//        signOut()
        view.backgroundColor = .red
    }
    
    //    MARK: - Selectors
    
    
    //    MARK: - Helpers
    
    //    MARK: - API
    
    func checkIfUserIsLoggedIn(){
        if Auth.auth().currentUser?.uid == nil {
            print("DEBUG: User not logged in!")
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }else{
            print("DEBUG: User is logged in!")
            print("DEBUG: UID: \(Auth.auth().currentUser!.uid)")
        }
    }
    
    func signOut(){
        do{
            try Auth.auth().signOut()
        }catch{
            print("DEBUG: \(error)")
        }
    }
}
