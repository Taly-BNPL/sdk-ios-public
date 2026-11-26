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

    private let clientIdTextField = UITextField()
    private let clientSecretTextField = UITextField()
    private let credentialErrorLabel = UILabel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        User.deleteLegacyUserDefaultsSecrets()

        showPasswordButton.contentMode = .scaleAspectFit
        showPasswordButton.setImage(UIImage(systemName: "eye"), for: .normal)
        showPasswordButton.addTarget(self, action: #selector(showPasswordButtonTapped), for: .touchUpInside)
        showPasswordButton.tintColor = .gray
        
        signInBtn.layer.cornerRadius = 10
        
        styleField(mailTextField, placeholder: "Merchant Key", isSecure: false)
        styleField(passwordTextField, placeholder: "Merchant Secret", isSecure: true)
        mailTextField.text = User.merchantKey
        passwordTextField.text = User.merchantSecret
        mailTextField.keyboardType = .default
        mailTextField.tag = 0
        passwordTextField.tag = 1
        
        enviromentView.layer.cornerRadius = 5
        enviromentView.clipsToBounds = true
        enviromentView.layer.borderWidth = 1.0
        enviromentView.layer.borderColor = UIColor.black.cgColor
        
        devlopmentButton.backgroundColor = UIColor.hexStringToUIColor(hex: "#233756")
        devlopmentButton.setTitleColor(UIColor.white, for: .normal)
        productionButton.setTitleColor(UIColor.black, for: .normal)

        setupClientCredentialFields()
        Utils.environment = environment
    }

    private func setupClientCredentialFields() {
        guard let container = passwordTextField.superview else { return }

        styleField(clientIdTextField, placeholder: "Client ID", isSecure: false)
        styleField(clientSecretTextField, placeholder: "Client Secret", isSecure: true)
        clientIdTextField.text = User.clientId
        clientSecretTextField.text = User.clientSecret
        clientIdTextField.tag = 2
        clientSecretTextField.tag = 3

        credentialErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        credentialErrorLabel.font = UIFont(name: "Manrope-Regular", size: 14)
        credentialErrorLabel.textColor = .systemRed
        credentialErrorLabel.numberOfLines = 0
        credentialErrorLabel.text = ""

        container.addSubview(clientIdTextField)
        container.addSubview(clientSecretTextField)
        container.addSubview(credentialErrorLabel)

        for constraint in container.constraints {
            if constraint.firstItem as? UIView == enviromentView, constraint.firstAttribute == .top {
                constraint.isActive = false
            }
            if constraint.firstAttribute == .height, constraint.firstItem as? UIView == container {
                constraint.constant = 540
            }
        }

        NSLayoutConstraint.activate([
            clientIdTextField.topAnchor.constraint(equalTo: textFieldValidationErrorLabelPassword.bottomAnchor, constant: 15),
            clientIdTextField.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor),
            clientIdTextField.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
            clientIdTextField.heightAnchor.constraint(equalToConstant: 45),
            clientSecretTextField.topAnchor.constraint(equalTo: clientIdTextField.bottomAnchor, constant: 15),
            clientSecretTextField.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor),
            clientSecretTextField.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
            clientSecretTextField.heightAnchor.constraint(equalToConstant: 45),
            credentialErrorLabel.topAnchor.constraint(equalTo: clientSecretTextField.bottomAnchor, constant: 5),
            credentialErrorLabel.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor),
            credentialErrorLabel.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
            enviromentView.topAnchor.constraint(equalTo: credentialErrorLabel.bottomAnchor, constant: 15)
        ])
    }

    private func styleField(_ field: UITextField, placeholder: String, isSecure: Bool) {
        field.delegate = self
        field.placeholder = placeholder
        field.isSecureTextEntry = isSecure
        field.isHidden = false
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.cornerRadius = 5
        field.clipsToBounds = true
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.black.cgColor
        field.setLeftPaddingPoints(10)
        if field.translatesAutoresizingMaskIntoConstraints {
            field.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    @objc private func showPasswordButtonTapped() {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? "eye" : "eye.slash"
        showPasswordButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @IBAction func loginBtnAction(_ sender: UIButton) {
        let merchantKey = mailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let merchantSecret = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let clientId = clientIdTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let clientSecret = clientSecretTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        textFieldValidationErrorLabelMail.text = ""
        textFieldValidationErrorLabelPassword.text = ""
        credentialErrorLabel.text = ""

        if merchantKey.isEmpty {
            textFieldValidationErrorLabelMail.text = "Please enter Merchant Key"
            return
        }
        if merchantSecret.isEmpty {
            textFieldValidationErrorLabelPassword.text = "Please enter Merchant Secret"
            return
        }
        if clientId.isEmpty {
            credentialErrorLabel.text = "Please enter Client ID"
            return
        }
        if clientSecret.isEmpty {
            credentialErrorLabel.text = "Please enter Client Secret"
            return
        }

        User.merchantKey = merchantKey
        User.merchantSecret = merchantSecret
        User.clientId = clientId
        User.clientSecret = clientSecret

        if let viewController = storyboard?.instantiateViewController(identifier: "ViewController") as? ViewController {
            viewController.userData = UserData(
                merchantKey: merchantKey,
                merchantSecret: merchantSecret,
                clientId: clientId,
                clientSecret: clientSecret,
                environment: self.environment
            )
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
        let nextTag = textField.tag + 1
        let nextResponder = textField.superview?.viewWithTag(nextTag) as UIResponder?
        if nextResponder != nil {
            nextResponder?.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
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
    var merchantKey: String
    var merchantSecret: String
    var clientId: String
    var clientSecret: String
    var environment: String
}
