//
//  LoginVC.swift
//  PaymentDemoApp
//
//  Created by Mehul Goswami on 11/07/23.
//

import UIKit
import TalySdk

class LoginVC: UIViewController {
    
    var activeField: UITextField!
    
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var showPasswordButton: UIButton!
    @IBOutlet weak var textFieldValidationErrorLabelMail: UILabel!
    @IBOutlet weak var textFieldValidationErrorLabelPassword: UILabel!
    var environment: String = "Development"
    
    @IBOutlet weak var enviromentView: UIView!
    @IBOutlet weak var devlopmentButton: UIButton!
    @IBOutlet weak var productionButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        User.deleteStoredMerchantSecrets()

        // The storyboard password field is unused. Checkout takes a server access token only.
        passwordTextField.isHidden = true
        showPasswordButton.isHidden = true
        textFieldValidationErrorLabelPassword.isHidden = true
        
        signInBtn.layer.cornerRadius = 10
        
        mailTextField.delegate = self
        mailTextField.placeholder = "Access token from your server"
        mailTextField.isSecureTextEntry = true
        mailTextField.autocapitalizationType = .none
        mailTextField.autocorrectionType = .no
        mailTextField.text = User.accessToken
        
        mailTextField.layer.cornerRadius = 5
        mailTextField.clipsToBounds = true
        mailTextField.layer.borderWidth = 1.0
        mailTextField.layer.borderColor = UIColor.black.cgColor
        mailTextField.setLeftPaddingPoints(10)
        
        enviromentView.layer.cornerRadius = 5
        enviromentView.clipsToBounds = true
        enviromentView.layer.borderWidth = 1.0
        enviromentView.layer.borderColor = UIColor.black.cgColor
        
        devlopmentButton.backgroundColor = UIColor.hexStringToUIColor(hex: "#233756")
        devlopmentButton.setTitleColor(UIColor.white, for: .normal)
        productionButton.setTitleColor(UIColor.black, for: .normal)

        Utils.environment = environment
    }
    
    @IBAction func loginBtnAction(_ sender: UIButton) {
        let accessToken = mailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !accessToken.isEmpty else {
            textFieldValidationErrorLabelMail.text = "Please enter an access token"
            return
        }
        textFieldValidationErrorLabelMail.text = ""
        User.accessToken = accessToken

        if let viewController = storyboard?.instantiateViewController(identifier: "ViewController") as? ViewController {
            viewController.userData = UserData(accessToken: accessToken, environment: self.environment)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func environmentBtnAction(_ sender: UIButton) {
        if sender == devlopmentButton {
            environment = "Development"
            productionButton.backgroundColor = UIColor.white
            productionButton.setTitleColor(UIColor.black, for: .normal)
        } else if sender == productionButton {
            environment = "Production"
            devlopmentButton.backgroundColor = UIColor.white
            devlopmentButton.setTitleColor(UIColor.black, for: .normal)
        }

        Utils.environment = environment
        sender.backgroundColor = UIColor.hexStringToUIColor(hex: "#233756")
        sender.setTitleColor(UIColor.white, for: .normal)
    }
    
}

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
}

struct UserData {
    var accessToken: String
    var environment: String
}
