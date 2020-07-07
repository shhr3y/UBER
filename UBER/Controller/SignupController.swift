//
//  SignupController.swift
//  UBER
//
//  Created by Shrey Gupta on 06/07/20.
//  Copyright © 2020 Shrey Gupta. All rights reserved.
//

import UIKit
import Firebase

class SignupController: UIViewController {
    //    MARK: - Properties
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "UBER"
        label.textColor = UIColor(white: 1, alpha: 0.8)
        label.font = UIFont(name: "Avenir-Light", size: 36)
        return label
    }()
    
    private lazy var emailContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_mail_outline_white_2x"), textField: emailTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var nameContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: nameTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var passwordContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: passwordTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var accountTypeContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_account_box_white_2x"), segmentedControl: accountTypeSegmentedControl)
        view.heightAnchor.constraint(equalToConstant: 120).isActive = true
        return view
    }()
    
    private let accountTypeSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Rider","Driver"])
        segmentedControl.backgroundColor = .backgroundColor
        segmentedControl.tintColor = UIColor(white: 1, alpha: 0.87)
        segmentedControl.selectedSegmentIndex = 0
        
        let selectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        let normalTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        segmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        
        return segmentedControl
    }()

 
    private let emailTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Email", isSecureText: false)
    }()
    private let nameTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Full Name", isSecureText: false)
    }()
    private let passwordTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Password", isSecureText: true)
    }()
    
    private let signupButton:  UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .mainBlueTint
        button.layer.cornerRadius = 5
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)

        button.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        return button
    }()
    
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account? ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Login", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.mainBlueTint]))
        
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    
    //    MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        initializeHideKeyboard()
    }
    
    //    MARK: - Selectors
    
    @objc func handleShowLogin(){
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleSignup(){
        if emailTextField.text != ""{
            if passwordTextField.text  != ""{
                if nameTextField.text != ""{
                    let email = emailTextField.text!
                    let password = passwordTextField.text!
                    let fullname = nameTextField.text!
                    let accountTypeSelectedIndex = accountTypeSegmentedControl.selectedSegmentIndex
                    Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                        if let error = error {
                            print("DEBUG: Error from CreateUser: ",error)
                            return
                        }else{
                            guard let uid = result?.user.uid else { return }
                            let userdata = ["email": email, "fullname": fullname, "accountTypeIndex": accountTypeSelectedIndex] as [String : Any]
                            
                            Database.database().reference().child("users").child(uid).updateChildValues(userdata) { (error, reference) in
                                if let error = error {
                                    print("DEBUG: Database from Database: ",error.localizedDescription)
                                }else{
                                    print("DEBUG: Succesfully registered User and saved in Database.")
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //    MARK: - Helper Functions
    
    func configureUI(){
        view.backgroundColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
        
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor,paddingTop: 120)
        titleLabel.centerX(inView: view)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView, nameContainerView, passwordContainerView, accountTypeContainerView, signupButton])
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor,
                     right: view.rightAnchor, paddingTop: 40, paddingLeft: 16,
                     paddingRight: 16)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.centerX(inView: view)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 32)
    }
    
    func initializeHideKeyboard(){
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissMyKeyboard))
    view.addGestureRecognizer(tap)
    }
    @objc func dismissMyKeyboard(){
    //endEditing causes the view (or one of its embedded text fields) to resign the first responder status.
    //In short- Dismiss the active keyboard.
    view.endEditing(true)
    }
}
