import Foundation
import UIKit

class ResetPasswordViewController: UIViewController {

    weak var delegate: NavigationFlow?
    weak var detector: DriveDetector? {
        didSet {
            oldValue?.remove(observer: self)
            detector?.add(observer: self)
        }
    }

    private let apiManager = DrivingNotifierAPIManager()
    private let managerOneSignal = OneSignalApiManager()

    private var formLabel = UILabel()
    private var emailInput = UITextField()
    private var emailLabel = UILabel()
    private var codeInput = UITextField()
    private var codeLabel = UILabel()
    private var passwordInput = UITextField()
    private var passwordLabel = UILabel()
    private var passwordInputTwice = UITextField()
    private var passwordTwiceLabel = UILabel()
    private var buttonResetPassword = UIButton()
    private var buttonSendCode = UIButton()

    override func viewDidLoad() { // swiftlint:disable:this function_body_length
        super.viewDidLoad()
        title = "Reset password"
        hideKeyboardWhenTappedAround()
        view.backgroundColor = Color.softWhite.value

        [emailInput, codeInput, passwordInput, passwordInputTwice].forEach { input in
            input.backgroundColor = UIColor.white
            input.borderStyle = .roundedRect
        }

        [formLabel, emailLabel, codeLabel, passwordLabel, passwordTwiceLabel].forEach { label in
            label.textColor = UIColor.red
            label.numberOfLines = 0
            label.isHidden = true
        }

        [buttonSendCode, buttonResetPassword].forEach { button in
            button.setTitleColor(Color.softWhite.value, for: .normal)
            button.backgroundColor = Color.cosmos.value
            button.isEnabled = true
            button.layer.borderColor = UIColor.darkText.cgColor
            button.layer.borderWidth = 2
            button.layer.cornerRadius = 6
        }

        emailInput.placeholder = "Email"
        emailInput.addTarget(self, action: #selector(validateEmail), for: .editingDidEnd)
        codeInput.placeholder = "Code"
        codeInput.addTarget(self, action: #selector(validateCode), for: .editingDidEnd)
        codeInput.isHidden = true
        passwordInput.placeholder = "Insert new password"
        passwordInput.isSecureTextEntry = true
        passwordInput.addTarget(self, action: #selector(validatePassword), for: .editingDidEnd)
        passwordInput.isHidden = true
        passwordInputTwice.placeholder = "Repeat password"
        passwordInputTwice.isSecureTextEntry = true
        passwordInputTwice.addTarget(self, action: #selector(validateRepeatedPassword), for: .editingDidEnd)
        passwordInputTwice.isHidden = true

        buttonResetPassword.setTitle("Reset password", for: .normal)
        buttonResetPassword.addTarget(self, action: #selector(validateForm), for: .touchDown)
        buttonResetPassword.isHidden = true

        buttonSendCode.setTitle("Send code", for: .normal)
        buttonSendCode.addTarget(self, action: #selector(sendCode), for: .touchDown)

        let stackView = UIStackView()
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        stackView.addArrangedSubview(formLabel)
        stackView.addArrangedSubview(emailInput)
        stackView.addArrangedSubview(emailLabel)
        stackView.addArrangedSubview(buttonSendCode)
        stackView.addArrangedSubview(codeInput)
        stackView.addArrangedSubview(codeLabel)
        stackView.addArrangedSubview(passwordInput)
        stackView.addArrangedSubview(passwordLabel)
        stackView.addArrangedSubview(passwordInputTwice)
        stackView.addArrangedSubview(passwordTwiceLabel)
        stackView.addArrangedSubview(buttonResetPassword)
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        stackView.spacing = 20

        let scrollView = UIScrollView(frame: .zero)
        scrollView.alwaysBounceVertical = true

        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }

        scrollView.snp.makeConstraints { make in
            make.edges.width.height.equalToSuperview()
        }
    }

    @objc func validateEmail() {
        guard let email = emailInput.text else { return }
        if email.isValid(regex: .email) {
            emailLabel.isHidden = true
            buttonResetPassword.isEnabled = true
        } else {
            buttonResetPassword.isEnabled = false
            emailLabel.isHidden = false
            emailLabel.text = "Insert a valid e-mail."
        }
    }

    @objc func validateCode() {
        guard let code = codeInput.text else { return }
        if code.count > 5 && code.count < 20 {
            codeLabel.isHidden = true
            buttonResetPassword.isEnabled = true

        } else {
            buttonResetPassword.isEnabled = false
            codeLabel.isHidden = false
            codeLabel.text = "Insert a valid code."
        }
    }

    @objc func validatePassword() {
        guard let password = passwordInput.text else { return }
        if password.isValid(regex: .password) {
            passwordLabel.isHidden = true
            buttonResetPassword.isEnabled = true
        } else {
            buttonResetPassword.isEnabled = false
            passwordLabel.isHidden = false
            passwordLabel.text = "Password must have minimum 8 characters at least 1 Alphabet and 1 Number."
        }
    }

    @objc func validateRepeatedPassword() {
        guard let repeatedPassword = passwordInputTwice.text else { return }
        if repeatedPassword.isValid(regex: .password) && repeatedPassword == passwordInput.text {
            passwordTwiceLabel.isHidden = true
            buttonResetPassword.isEnabled = true
        } else {
            buttonResetPassword.isEnabled = false
            passwordTwiceLabel.isHidden = false
            passwordTwiceLabel.text = "Password must match in both fields."
        }
    }

    func sendCodeHandler(data: Data?, response: URLResponse?, error: Error?) {
        let httpResponse = response as? HTTPURLResponse
        if httpResponse?.statusCode == 200 {

            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.buttonSendCode.isHidden = true
                strongSelf.codeInput.isHidden = false
                strongSelf.passwordInput.isHidden = false
                strongSelf.passwordInputTwice.isHidden = false
                strongSelf.buttonResetPassword.isHidden = false
            }
        }
    }

    func resetPasswordHandler(data: Data?, response: URLResponse?, error: Error?) {
        let httpResponse = response as? HTTPURLResponse
        if httpResponse?.statusCode == 200 {

            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.navigate(from: strongSelf)
            }
        }
    }

    @objc func sendCode(sender: UIButton) {
        sender.preventRepeatedPresses()
        guard let email = emailInput.text else { return }
        if email.isValid(regex: .email) {
            emailLabel.isHidden = true
            apiManager.performOperation(
                route: .resetPasswordForUserWith(email: email),
                method: .GET,
                completionHandler: sendCodeHandler)
        } else {
            emailLabel.isHidden = false
            emailLabel.text = "Insert a valid e-mail."
        }
    }

    @objc func validateForm(sender: UIButton) {
        sender.preventRepeatedPresses()
        var inputs = [emailInput, codeInput, passwordInput, passwordInputTwice]
        inputs = inputs.filter { $0.text?.count == 0}
        if inputs.count > 0 {
            formLabel.isHidden = false
            formLabel.text = "Complete all the fields!"
            return
        } else {
            formLabel.isHidden = true
        }

        guard let email = emailInput.text,
            let password = passwordInput.text?.md5().sha1(),
            let code = codeInput.text
            else { return }

        let parameters = [
            "resetCode": code,
            "password": password,
            "email": email
            ] as [String: Any]

            apiManager.performOperation(
                parameters: parameters,
                route: .updatePassword,
                method: .POST,
                completionHandler: resetPasswordHandler)
    }
}
