//
//  ViewController.swift
//  Roommater
//
//  Created by KAMIKU on 10/5/21.
//

import UIKit
import SPIndicator
import SkyFloatingLabelTextField
import TransitionButton

class AuthNavVC: UINavigationController {
    static var shared: AuthNavVC!

    override func viewDidLoad() {
        super.viewDidLoad()
        if AuthNavVC.shared == nil {
            AuthNavVC.shared = self
        } else {
            self.dismiss(animated: false) {
                AuthNavVC.shared.present(self, animated: false, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        check();
    }

    func check() {
        if SessionManager.instance.userPreCheck() {
            self.performSegue(withIdentifier: "dashboardPage", sender: self)
            APIAction.loginToken(callback: { res in
                switch res {
                case .Success:
                    SPIndicator.present(title: "Welcome Back!", preset: .done)
                case .Fail(let msg), .Timeout(let msg), .Error(let msg), .NONE(let msg):
                    SPIndicator.present(title: msg, preset: .error)
                    SessionManager.instance.close()
                    self.popViewController(animated: true)
                }
            })
        }
    }
}

class LoginViewController: PrototypeViewController {
    @IBOutlet var usernameTextField: SkyFloatingLabelTextField!
    @IBOutlet var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet var forgotPassword: UIButton!
    @IBOutlet var jumpToSignUp: UIButton!
    @IBOutlet var login: TransitionButton!

    func exec() {
        self.disableAllTextField()
        APIAction.login(username: usernameTextField.text!, pass: passwordTextField.text!) { res in
            switch res {
            case .Success(let data):
                self.login.stopAnimation(animationStyle: .expand, completion: {
                    self.navigationController?.performSegue(withIdentifier: "dashboardPage", sender: data)
                })
                self.reset()
            case .Fail(let msg), .Timeout(let msg), .Error(let msg), .NONE(let msg):
                self.login.stopAnimation(animationStyle: .shake, completion: {
                    SPIndicator.present(title: msg, preset: .error)
                    self.reset()
                })
            }
        }
    }

    override func viewLoadAction() {
        let textFieldHeight = usernameTextField.frame.maxY - usernameTextField.frame.minY

        usernameTextField.frame.origin.x = WIDTH / 2 - usernameTextField.frame.width / 2
        usernameTextField.frame.origin.y = HEIGHT / 3
        usernameTextField.tag = 0
        usernameTextField.returnKeyType = .next
        usernameTextField.enablesReturnKeyAutomatically = true
        usernameTextField.spellCheckingType = .no
        usernameTextField.clearButtonMode = .whileEditing
        usernameTextField.placeholder = "Username"
        usernameTextField.title = "Your Username"
        usernameTextField.tintColor = overcastBlueColor
        usernameTextField.errorColor = .red
        usernameTextField.selectedTitleColor = overcastBlueColor
        usernameTextField.selectedLineColor = overcastBlueColor
        usernameTextField.addTarget(self, action: #selector(textFieldAction(_:)), for: .editingChanged)

        forgotPassword.frame.origin.y = usernameTextField.frame.maxY + textFieldHeight / 2

        passwordTextField.frame.origin.x = WIDTH / 2 - passwordTextField.frame.width / 2
        passwordTextField.frame.origin.y = usernameTextField.frame.maxY + textFieldHeight

        forgotPassword.frame.origin.x = passwordTextField.frame.maxX - forgotPassword.frame.width
        
        passwordTextField.tag = 1
        passwordTextField.returnKeyType = .done
        passwordTextField.enablesReturnKeyAutomatically = true
        passwordTextField.spellCheckingType = .no
        passwordTextField.clearButtonMode = .whileEditing
        passwordTextField.isSecureTextEntry = true
        passwordTextField.placeholder = "Password"
        passwordTextField.title = "Your Password"
        passwordTextField.tintColor = overcastBlueColor
        passwordTextField.errorColor = .red
        passwordTextField.selectedTitleColor = overcastBlueColor
        passwordTextField.selectedLineColor = overcastBlueColor
        passwordTextField.addTarget(self, action: #selector(textFieldAction(_:)), for: .editingChanged)


        login.frame.origin.x = WIDTH / 2 - login.frame.width / 2
        login.frame.origin.y = passwordTextField.frame.maxY + textFieldHeight

        login.setTitle("Login", for: .normal)
        login.cornerRadius = 20
        disableLoginButton()
        login.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)

        jumpToSignUp.frame.origin.x = WIDTH / 2 - jumpToSignUp.frame.width / 2
        jumpToSignUp.frame.origin.y = login.frame.maxY + textFieldHeight
    }

    func disableLoginButton() {
        login.backgroundColor = .systemGray5
        login.isUserInteractionEnabled = false
        login.spinnerColor = .systemGray3
    }

    func enableLoginButton() {
        login.backgroundColor = overcastBlueColor
        login.isUserInteractionEnabled = true
        login.spinnerColor = .white
    }

    func reset() {
        enableAllTextField()
        usernameTextField.text = ""
        passwordTextField.text = ""
        enableLoginButton()
    }

    private func checkUsername() -> Bool {
        return usernameMatcher.match(input: usernameTextField.text!)
    }

    private func checkPassword() -> Bool {
        return passwordMatcher.match(input: passwordTextField.text!)
    }

    func checkTextFieldAction(_ textField: UITextField) -> Bool {
        if (textField.isKind(of: SkyFloatingLabelTextField.self)) {
            switch (textField.tag) {
            case 0:
                usernameTextField.errorMessage = checkUsername() ? "" : "Invalid Username"
                return checkUsername()
            case 1:
                passwordTextField.errorMessage = checkPassword() ? "" : "Invalid Password"
                return checkPassword()
            default:
                return false
            }
        }
        return false
    }

    override func textFieldAction(_ textField: UITextField) {
        if checkTextFieldAction(textField), checkUsername(), checkPassword() {
            enableLoginButton()
        } else {
            disableLoginButton()
        }
    }

    @IBAction func buttonAction(_ button: TransitionButton) {
        login.startAnimation()
        exec()
    }

    override func textFieldDone(_ textField: UITextField) {
        textField.resignFirstResponder()
//        buttonAction(login)
    }
}

class SignupViewController: PrototypeViewController {
    @IBOutlet var nicknameTextField: SkyFloatingLabelTextField!
    @IBOutlet var usernameTextField: SkyFloatingLabelTextField!
    @IBOutlet var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet var rePasswordTextField: SkyFloatingLabelTextField!
    @IBOutlet var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet var backLogin: UIButton!
    @IBOutlet var signup: TransitionButton!

    func disableSignupButton() {
        signup.backgroundColor = .systemGray5
        signup.isUserInteractionEnabled = false
        signup.spinnerColor = .systemGray3
    }

    func enableSignupButton() {
        signup.backgroundColor = overcastBlueColor
        signup.isUserInteractionEnabled = true
        signup.spinnerColor = .white
    }

    func exec() {
        self.disableAllTextField()
        APIAction.signup(username: usernameTextField.text!, pass: passwordTextField.text!, email: emailTextField.text!, name: nicknameTextField.text!) { res in
            switch res {
            case .Success(_):
                self.signup.stopAnimation(animationStyle: .expand, completion: {
                    self.navigationController?.popViewController(animated: true)
                    SPIndicator.present(title: "Success", message: "Successfully send! Please check your email!", preset: .done)
                })
            case .Fail(let msg), .Timeout(let msg), .Error(let msg), .NONE(let msg):
                self.signup.stopAnimation(animationStyle: .shake, completion: { SPIndicator.present(title: msg, preset: .error) })
            }
        }
    }

    @IBAction func buttonAction(_ button: TransitionButton) {
        signup.startAnimation()
        exec()
    }

    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    override func textFieldAction(_ textField: UITextField) {
        if checkTextFieldAction(textField), checkUsername(), checkPassword(), checkRePassword(), checkEmail() {
            enableSignupButton()
        } else {
            disableSignupButton()
        }
    }

    func checkTextFieldAction(_ textField: UITextField) -> Bool {
        if (textField.isKind(of: SkyFloatingLabelTextField.self)) {
            switch (textField.tag) {
            case 0:
                if nicknameTextField.text! == "" {
                    nicknameTextField.errorMessage = "Please enter a nickname!"
                    return false
                }else{
                    nicknameTextField.errorMessage = ""
                    return true
                }
            case 1:
                usernameTextField.errorMessage = checkUsernameStr()
                return (checkUsernameStr() == "")
            case 2:
                passwordTextField.errorMessage = checkPasswordStr()
                return (checkPasswordStr() == "")
            case 3:
                rePasswordTextField.errorMessage = checkRePassword() ? "" : "Different from Password"
                return checkRePassword()
            case 4:
                emailTextField.errorMessage = checkEmail() ? "" : "Invalid Email Address"
                return checkEmail()
            default:
                return false
            }
        }
        return false

    }

    private func checkUsernameStr() -> String {
        if !(usernameMatcher.match(input: usernameTextField.text!)) {
            if !(noSpecialCharMatcher.match(input: usernameTextField.text!)) {
                return regexErrMsg["noSpeChar"]!
            }
            if !(lower4LimitedMatcher.match(input: usernameTextField.text!)) {
                return regexErrMsg["lower4Limited"]!
            }
            if !(upperLimitedMatcher.match(input: usernameTextField.text!)) {
                return regexErrMsg["upperLimited"]!
            }
        }
        return ""
    }

    private func checkPasswordStr() -> String {
        if !(passwordMatcher.match(input: passwordTextField.text!)) {
            if !(specialCharRequireMatcher.match(input: passwordTextField.text!)) {
                return regexErrMsg["speChar"]!
            }
            if !(digitRequireMatcher.match(input: passwordTextField.text!)) {
                return regexErrMsg["digit"]!
            }
            if !(uppercaseRequireMatcher.match(input: passwordTextField.text!)) {
                return regexErrMsg["uppercase"]!
            }
            if !(lowercaseRequireMatcher.match(input: passwordTextField.text!)) {
                return regexErrMsg["lowercase"]!
            }
            if !(lower8LimitedMatcher.match(input: passwordTextField.text!)) {
                return regexErrMsg["lower8Limited"]!
            }
            if !(upperLimitedMatcher.match(input: usernameTextField.text!)) {
                return regexErrMsg["upperLimited"]!
            }
        }
        return ""
    }

    private func checkUsername() -> Bool {
        return usernameMatcher.match(input: usernameTextField.text!)
    }

    private func checkPassword() -> Bool {
        return passwordMatcher.match(input: passwordTextField.text!)
    }

    private func checkRePassword() -> Bool {
        return rePasswordTextField.text! == passwordTextField.text!
    }

    private func checkEmail() -> Bool {
        return emailMatcher.match(input: emailTextField.text!)
    }

    override func viewLoadAction() {
        let buttonHeight = backLogin.frame.height
        let textFieldHeight = nicknameTextField.frame.height

        backLogin.frame.origin.x = WIDTH / 2 - backLogin.frame.width / 2
        backLogin.frame.origin.y = HEIGHT / 30 + buttonHeight / 2


        nicknameTextField.frame.origin.x = WIDTH / 2 - nicknameTextField.frame.width / 2
        nicknameTextField.frame.origin.y = backLogin.frame.maxY + textFieldHeight / 2
        nicknameTextField.tag = 0
        nicknameTextField.returnKeyType = .next
        nicknameTextField.enablesReturnKeyAutomatically = true
        nicknameTextField.spellCheckingType = .no
        nicknameTextField.clearButtonMode = .whileEditing
        nicknameTextField.placeholder = "Nickname"
        nicknameTextField.title = "Your nickname"
        nicknameTextField.tintColor = overcastBlueColor
        nicknameTextField.errorColor = .red
        nicknameTextField.selectedTitleColor = overcastBlueColor
        nicknameTextField.selectedLineColor = overcastBlueColor
        nicknameTextField.addTarget(self, action: #selector(textFieldAction(_:)), for: .editingChanged)
        
        usernameTextField.frame.origin.x = WIDTH / 2 - usernameTextField.frame.width / 2
        usernameTextField.frame.origin.y = nicknameTextField.frame.maxY + textFieldHeight / 2
        usernameTextField.tag = 1
        usernameTextField.returnKeyType = .next
        usernameTextField.enablesReturnKeyAutomatically = true
        usernameTextField.spellCheckingType = .no
        usernameTextField.clearButtonMode = .whileEditing
        usernameTextField.placeholder = "Username"
        usernameTextField.title = "Your username"
        usernameTextField.tintColor = overcastBlueColor
        usernameTextField.errorColor = .red
        usernameTextField.selectedTitleColor = overcastBlueColor
        usernameTextField.selectedLineColor = overcastBlueColor
        usernameTextField.addTarget(self, action: #selector(textFieldAction(_:)), for: .editingChanged)

        passwordTextField.frame.origin.x = WIDTH / 2 - passwordTextField.frame.width / 2
        passwordTextField.frame.origin.y = usernameTextField.frame.maxY + textFieldHeight / 4
        passwordTextField.tag = 2
        passwordTextField.returnKeyType = .next
        passwordTextField.spellCheckingType = .no
        passwordTextField.enablesReturnKeyAutomatically = true
        passwordTextField.clearButtonMode = .whileEditing
        passwordTextField.isSecureTextEntry = true
        passwordTextField.placeholder = "Password"
        passwordTextField.title = "Your password"
        passwordTextField.tintColor = overcastBlueColor
        passwordTextField.errorColor = .red
        passwordTextField.selectedTitleColor = overcastBlueColor
        passwordTextField.selectedLineColor = overcastBlueColor
        passwordTextField.addTarget(self, action: #selector(textFieldAction(_:)), for: .editingChanged)

        rePasswordTextField.frame.origin.x = WIDTH / 2 - rePasswordTextField.frame.width / 2
        rePasswordTextField.frame.origin.y = passwordTextField.frame.maxY + textFieldHeight / 4
        rePasswordTextField.tag = 3
        rePasswordTextField.returnKeyType = .next
        rePasswordTextField.spellCheckingType = .no
        rePasswordTextField.enablesReturnKeyAutomatically = true
        rePasswordTextField.clearButtonMode = .whileEditing
        rePasswordTextField.isSecureTextEntry = true
        rePasswordTextField.placeholder = "Confirm Password"
        rePasswordTextField.title = "Confirm Password"
        rePasswordTextField.tintColor = overcastBlueColor
        rePasswordTextField.errorColor = .red
        rePasswordTextField.selectedTitleColor = overcastBlueColor
        rePasswordTextField.selectedLineColor = overcastBlueColor
        rePasswordTextField.addTarget(self, action: #selector(textFieldAction(_:)), for: .editingChanged)


        emailTextField.frame.origin.x = WIDTH / 2 - emailTextField.frame.width / 2
        emailTextField.frame.origin.y = rePasswordTextField.frame.maxY + textFieldHeight / 4
        emailTextField.tag = 4
        emailTextField.returnKeyType = .done
        emailTextField.spellCheckingType = .no
        emailTextField.enablesReturnKeyAutomatically = true
        emailTextField.clearButtonMode = .whileEditing
        emailTextField.spellCheckingType = .no
        emailTextField.placeholder = "E-mail"
        emailTextField.title = "Your E-mail"
        emailTextField.tintColor = overcastBlueColor
        emailTextField.errorColor = .red
        emailTextField.selectedTitleColor = overcastBlueColor
        emailTextField.selectedLineColor = overcastBlueColor
        emailTextField.addTarget(self, action: #selector(textFieldAction(_:)), for: .editingChanged)

        signup.frame.origin.y = emailTextField.frame.maxY + textFieldHeight / 4
        signup.frame.origin.x = WIDTH / 2 - signup.frame.width / 2
        signup.setTitle("Signup", for: .normal)
        signup.cornerRadius = 20

        disableSignupButton()
        signup.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
    }

    override func textFieldDone(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}

class ForgotPasswordViewController: PrototypeViewController {
    @IBOutlet var backToLoginButton: PrototypeButton!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet var resetButton: TransitionButton!

    func exec() {
        self.disableAllTextField()
        APIAction.forgot(email: emailTextField.text!, callback: handle)
    }

    func handle(res: Result) {
        switch res {
        case .Success(_):
            self.resetButton.stopAnimation(animationStyle: .expand, completion: {
                self.navigationController?.popViewController(animated: true)
                SPIndicator.present(title: "Success", message: "Successfully send! Please check your email!", preset: .done)
            })
        case .Fail(let msg), .Timeout(let msg), .Error(let msg), .NONE(let msg):
            self.resetButton.stopAnimation(animationStyle: .shake, completion: {
                SPIndicator.present(title: "Error", message: msg, preset: .error)
                self.enableAllTextField()
            })
        }
    }

    func disableResetButton() {
        resetButton.backgroundColor = .systemGray5
        resetButton.isUserInteractionEnabled = false
        resetButton.spinnerColor = .systemGray3
    }

    func enableResetButton() {
        resetButton.backgroundColor = overcastBlueColor
        resetButton.isUserInteractionEnabled = true
        resetButton.spinnerColor = .white
    }

    @IBAction func buttonAction(_ button: TransitionButton) {
        resetButton.startAnimation()
        exec()
    }

    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewLoadAction() {
        let buttonHeight = backToLoginButton.frame.height
        let textFieldHeight = emailTextField.frame.height

        backToLoginButton.frame.origin.x = WIDTH / 2 - backToLoginButton.frame.width / 2
        backToLoginButton.frame.origin.y = HEIGHT / 30 + buttonHeight / 2

        emailLabel.frame.origin.x = WIDTH / 2 - emailLabel.frame.width / 2
        emailLabel.frame.origin.y = backToLoginButton.frame.maxY
        emailTextField.frame.origin.x = WIDTH / 2 - emailTextField.frame.width / 2
        emailTextField.frame.origin.y = emailLabel.frame.maxY

        emailTextField.placeholder = "E-mail"
        emailTextField.title = "Your E-mail Address"
        emailTextField.tintColor = overcastBlueColor
        emailTextField.errorColor = .red
        emailTextField.returnKeyType = .done
        emailTextField.enablesReturnKeyAutomatically = true
        emailTextField.spellCheckingType = .no
        emailTextField.selectedTitleColor = overcastBlueColor
        emailTextField.selectedLineColor = overcastBlueColor
        emailTextField.addTarget(self, action: #selector(textFieldAction(_:)), for: .editingChanged)

        resetButton.frame.origin.x = emailTextField.frame.midX - resetButton.frame.width / 2
        resetButton.frame.origin.y = emailTextField.frame.maxY + textFieldHeight / 2
        resetButton.setTitle("Send", for: .normal)
        resetButton.cornerRadius = 20
        disableResetButton()
        resetButton.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
    }

    private func checkEmail() -> Bool {
        return emailMatcher.match(input: emailTextField.text!)
    }

    func EmailTextFieldCheckAction() -> Bool {
        if checkEmail() {
            emailTextField.errorMessage = ""
        } else {
            emailTextField.errorMessage = "Invalid email format"
        }
        return checkEmail()
    }

    override func textFieldAction(_ textField: UITextField) {
        if EmailTextFieldCheckAction() {
            enableResetButton()
        } else {
            disableResetButton()
        }
    }

    override func textFieldDone(_ textField: UITextField) {
        textField.resignFirstResponder()
//        buttonAction(resetButton)
    }
}
