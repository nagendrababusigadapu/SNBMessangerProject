//
//  ViewController.swift
//  SNBMessanger
//
//  Created by Nagendra on 27/01/21.
//

import UIKit
import ProgressHUD

class LoginViewController: UIViewController {
    
    //MARK:- IBOutlets
    //Labels
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var repeatPasswordLabel: UILabel!
    @IBOutlet weak var haveAnAccountLabel: UILabel!
    //textFields
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    //Buttons
    
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var forgotPasswordBtn: UIButton!
    @IBOutlet weak var resendEmailBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    //Views

    @IBOutlet weak var repeatPasswordBottomLine: UIView!
    
    //MARK:- Properties
    
    var isLogin = true
    
    //MARK:- View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIFor(login: isLogin)
        setupUI()
    }
    
    
    //MARK:- Custom method
    
    private func setupUI(){
        
        setupTargetsForTextFields()
        setupBackgroundTap()
    }
    
    private func setupTargetsForTextFields(){
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        repeatPasswordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    private func setupUIFor(login:Bool){
        
        loginBtn.setImage(UIImage(named: login ? "loginBtn" : "registerBtn"), for: .normal)
        signUpBtn.setTitle(login ? "Sign up" : "Sign in", for: .normal)
        haveAnAccountLabel.text = login ? "Don't have an account" : "Have an account?"
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                self.repeatPasswordLabel.isHidden = login
                self.repeatPasswordTextField.isHidden = login
                self.repeatPasswordBottomLine.isHidden = login
            }
        }
    }
    
    private func setupBackgroundTap(){
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func backgroundTap(){
        view.endEditing(false)
    }
    
    
    //MARK:- Selectors
    
    
    @objc private func textFieldDidChange(_ textField: UITextField){
        updateTextFieldPlaceHolder(textField)
    }
    
    private func updateTextFieldPlaceHolder(_ textField: UITextField){
        
        switch textField {
        case emailTextField:
            emailLabel.text = textField.hasText ? "Email" : ""
        case passwordTextField:
            passwordLabel.text = textField.hasText ? "Password" : ""
        default:
            repeatPasswordLabel.text = textField.hasText ? "Repeat Password" : ""
        }
    }
    
    
    //MARK:- IBActions
    
    @IBAction func loginBtnTapped(_ sender: Any) {
        
        if isDataInputedFor(type: isLogin ? "Login" : "Registration"){
            isLogin ? loginUser() : registerUser()
        }else{
            ProgressHUD.showFailed("All fields are required.")
        }
    }
    

    @IBAction func forgotPasswordBtnTapped(_ sender: Any)
    {
        if isDataInputedFor(type: "Password"){
            resetPassword()
        }else{
            ProgressHUD.showFailed("Email is required.")
        }
        
    }
    
    @IBAction func resendEmailBtnTapped(_ sender: Any) {
        
        if isDataInputedFor(type: "Password"){
           resendEmail()
        }else{
            ProgressHUD.showFailed("Email is required.")
        }
        
    }
    
    
    @IBAction func signupBtnTapped(_ sender: UIButton) {
        setupUIFor(login: sender.titleLabel?.text == "Sign in")
        isLogin.toggle()
    }
    
    //MARK:- Helpers
    
    private func isDataInputedFor(type:String) -> Bool{
        
        switch type {
        case "Login":
            return emailTextField.text != "" && passwordTextField.text != ""
        case "Registration":
            return emailTextField.text != "" && passwordTextField.text != "" && repeatPasswordTextField.text != ""
        default:
            return emailTextField.text != ""
        }
    }
    
    private func registerUser(){
        
        if passwordTextField.text == repeatPasswordTextField.text {
            FirebaseUserListener.shared.registerUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
                
                if error == nil {
                    ProgressHUD.showSuccess("Verification email has been sent.")
                    self.resendEmailBtn.isHidden = false
                }else{
                    ProgressHUD.showFailed(error?.localizedDescription)
                }
            }
        }else{
            ProgressHUD.showFailed("Password doesn't match.")
        }
    }
    
    private func loginUser(){
        ProgressHUD.show()
        FirebaseUserListener.shared.loginUserWithEmail(email: emailTextField.text!, password: passwordTextField.text!) { (error, isEmailVerified) in
            
            if error == nil {
                if isEmailVerified {
                    self.goToHome()
                }else{
                    ProgressHUD.showFailed("Please verify email.")
                    self.resendEmailBtn.isHidden = false
                }
            }else{
                ProgressHUD.showFailed(error?.localizedDescription)
            }
        }
    }
    
    
    private func resetPassword(){
        
        FirebaseUserListener.shared.resetPasswordFor(email: emailTextField.text!) { (error) in
            
            if error == nil {
                ProgressHUD.showSuccess("Reset link sent to email.")
            }else{
                ProgressHUD.showFailed(error?.localizedDescription)
            }
        }
    }
    
    private func resendEmail(){
        
        FirebaseUserListener.shared.resendVerificationLinkWith(email: emailTextField.text!) { (error) in
            
            if error == nil {
                ProgressHUD.showSuccess("New verification email is sent.")
            }else{
                ProgressHUD.showFailed(error?.localizedDescription)
            }
        }
    }
    
    
    //MARK:- Navigation
    
    private func goToHome(){
      
        let homeVC = self.storyboard?.instantiateViewController(identifier: HOMESCREEN) as! UITabBarController
        homeVC.modalPresentationStyle = .fullScreen
        present(homeVC, animated: true, completion: nil)
    }
}


