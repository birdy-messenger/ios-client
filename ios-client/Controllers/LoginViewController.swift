//
//  LoginViewController.swift
//  ios-client
//
//  Created by Vsevolod Konyakhin on 05/06/2019.
//  Copyright © 2019 Vsevolod Konyakhin. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.sandy
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    let defaultProfileImage: String = "https://firebasestorage.googleapis.com/v0/b/birdy-de1c1.appspot.com/o/birb.png?alt=media&token=86225bef-2918-430d-89b5-460a3be33e79"
    
    let registerButtonView: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        button.backgroundColor = UIColor.customRed
        
        button.addTarget(self, action: #selector(registerButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    @objc func registerButtonPressed() {
        loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? handleLogin() : handleRegister()
    }
    
    func handleLogin() {
        guard let email = emailTextField.text else {
            NSLog("Error while parsing user email")
            return
        }
        
        guard let password = passwordTextField.text else {
            NSLog("Error while parsing user password")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                return
            }
            
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func handleRegister() {
        guard let email = emailTextField.text else {
            NSLog("Error while parsing user email")
            return
        }
        
        guard let name = nameTextField.text else {
            NSLog("Error while parsing user name")
            return
        }
        
        guard let password = passwordTextField.text else {
            NSLog("Error while parsing user password")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                NSLog("Error while creating new user")
                print(error!)
                return
            }
            
            guard let userID = user?.user.uid else {
                return
            }
            
            let ref = Database.database().reference(fromURL: "https://birdy-de1c1.firebaseio.com/")
            let userReference = ref.child("users").child(userID)
            let values = ["name": name, "email": email, "profileImageUrl": self.defaultProfileImage]
            userReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
                if error != nil {
                    NSLog("Error while updating values in Database")
                    print(error!)
                    return
                }
            })
            
            
            self.dismiss(animated: true, completion: nil)
        })
        

    }
    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 1
        sc.tintColor = UIColor.customRed
        sc.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)], for: .normal)
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    @objc func handleLoginRegisterChange() {
        registerButtonView.setTitle(loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? "Login" : "Register", for: .normal)
        inputContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        nameTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor?.isActive = false
        
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0.5 : 1/3)
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0.5 : 1/3)
        
        nameTextFieldHeightAnchor?.isActive = true
        emailTextFieldHeightAnchor?.isActive = true
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        textField.textColor = .white
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        textField.textColor = .white
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        textField.textColor = .white
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let nameFieldSeparator: UIView = {
        let separator = UIView()
        separator.backgroundColor = .white
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }()
    
    let emailFieldSeparator: UIView = {
        let separator = UIView()
        separator.backgroundColor = .white
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }()
    
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Logo")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(inputContainerView)
        setupInputContainerViewConstraints()
        
        view.addSubview(registerButtonView)
        setupRegisterButtonViewConstraints()
        
        view.addSubview(loginRegisterSegmentedControl)
        setupLoginRegisterSegmentedControlConstraints()
        
        view.addSubview(logoImageView)
        setupLogoImageViewConstraints()
        
        view.backgroundColor = .white
        
        hideKeyboard()
    }
    
    var inputContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    func setupInputContainerViewConstraints() {
        inputContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputContainerViewHeightAnchor = inputContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputContainerViewHeightAnchor?.isActive = true
        
        inputContainerView.addSubview(nameTextField)
        inputContainerView.addSubview(emailTextField)
        inputContainerView.addSubview(passwordTextField)
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        nameTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
        nameTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 8).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 8).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 8).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
        inputContainerView.addSubview(nameFieldSeparator)
        
        nameFieldSeparator.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameFieldSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        nameFieldSeparator.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        nameFieldSeparator.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        
        inputContainerView.addSubview(emailFieldSeparator)
        
        emailFieldSeparator.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailFieldSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        emailFieldSeparator.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        emailFieldSeparator.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
    }
    
    func setupRegisterButtonViewConstraints() {
        registerButtonView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerButtonView.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: 10).isActive = true
        registerButtonView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        registerButtonView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setupLogoImageViewConstraints() {
        logoImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -12).isActive = true
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    func setupLoginRegisterSegmentedControlConstraints() {
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor, multiplier: 1).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

}


extension UIViewController {
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
