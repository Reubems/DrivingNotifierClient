import Foundation
import UIKit

class RegisterViewController: UIViewController {

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
    private var fullNameInput = UITextField()
    private var fullNameLabel = UILabel()
    private var emailInput = UITextField()
    private var emailLabel = UILabel()
    private var passwordInput = UITextField()
    private var passwordLabel = UILabel()
    private var passwordInputTwice = UITextField()
    private var passwordTwiceLabel = UILabel()
    private var button = UIButton()

    override func viewDidLoad() { // swiftlint:disable:this function_body_length
        super.viewDidLoad()
        title = "Register"
        hideKeyboardWhenTappedAround()
        view.backgroundColor = Color.softWhite.value

        [fullNameInput, emailInput, passwordInput, passwordInputTwice].forEach { input in
            input.backgroundColor = UIColor.white
            input.borderStyle = .roundedRect
        }

        [formLabel, fullNameLabel, emailLabel, passwordLabel, passwordTwiceLabel].forEach { label in
            label.textColor = UIColor.red
            label.numberOfLines = 0
            label.isHidden = true
        }

        fullNameInput.placeholder = "Full name"
        fullNameInput.addTarget(self, action: #selector(validateFullName), for: .editingDidEnd)
        emailInput.placeholder = "Email"
        emailInput.addTarget(self, action: #selector(validateEmail), for: .editingDidEnd)
        passwordInput.placeholder = "Insert password"
        passwordInput.isSecureTextEntry = true
        passwordInput.addTarget(self, action: #selector(validatePassword), for: .editingDidEnd)
        passwordInputTwice.placeholder = "Repeat password"
        passwordInputTwice.isSecureTextEntry = true
        passwordInputTwice.addTarget(self, action: #selector(validateRepeatedPassword), for: .editingDidEnd)

        button.setTitle("Register", for: .normal)
        button.setTitleColor(Color.softWhite.value, for: .normal)
        button.backgroundColor = Color.cosmos.value
        button.isEnabled = true
        button.layer.borderColor = UIColor.darkText.cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 6
        button.addTarget(self, action: #selector(validateForm), for: .touchDown)

        let stackView = UIStackView()
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        stackView.addArrangedSubview(formLabel)
        stackView.addArrangedSubview(fullNameInput)
        stackView.addArrangedSubview(fullNameLabel)
        stackView.addArrangedSubview(emailInput)
        stackView.addArrangedSubview(emailLabel)
        stackView.addArrangedSubview(passwordInput)
        stackView.addArrangedSubview(passwordLabel)
        stackView.addArrangedSubview(passwordInputTwice)
        stackView.addArrangedSubview(passwordTwiceLabel)
        stackView.addArrangedSubview(button)
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

    func handleRegister(data: Data?, response: URLResponse?, error: Error?) {
        let httpResponse = response as? HTTPURLResponse

        if httpResponse?.statusCode == 200 {

            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.navigate(from: strongSelf)
            }
        }
    }

    @objc func validateFullName() {
        guard let name = fullNameInput.text else { return }
        if name.count > 5 && name.count < 30 {
            fullNameLabel.isHidden = true
            button.isEnabled = true
        } else {
            button.isEnabled = false
            fullNameLabel.isHidden = false
            fullNameLabel.text = "The full name must have between 5 and 30 characters."
        }
    }

    @objc func validateEmail() {
        guard let email = emailInput.text else { return }
        if email.isValid(regex: .email) {
            emailLabel.isHidden = true
            button.isEnabled = true
        } else {
            button.isEnabled = false
            emailLabel.isHidden = false
            emailLabel.text = "Insert a valid e-mail."
        }
    }

    @objc func validatePassword() {
        guard let password = passwordInput.text else { return }
        if password.isValid(regex: .password) {
            passwordLabel.isHidden = true
            button.isEnabled = true
        } else {
            button.isEnabled = false
            passwordLabel.isHidden = false
            passwordLabel.text = "Password must have minimum 8 characters at least 1 Alphabet and 1 Number."
        }
    }

    @objc func validateRepeatedPassword() {
        guard let repeatedPassword = passwordInputTwice.text else { return }
        if repeatedPassword.isValid(regex: .password) && repeatedPassword == passwordInput.text {
            passwordTwiceLabel.isHidden = true
            button.isEnabled = true
        } else {
            button.isEnabled = false
            passwordTwiceLabel.isHidden = false
            passwordTwiceLabel.text = "Password must match in both fields."
        }
    }

    @objc func validateForm(sender: UIButton) {
        sender.preventRepeatedPresses()
        var inputs = [fullNameInput, emailInput, passwordInput, passwordInputTwice]
        inputs = inputs.filter { $0.text?.count == 0}
        if inputs.count > 0 {
            formLabel.isHidden = false
            formLabel.text = "Complete all the fields!"
            return
        } else {
            formLabel.isHidden = true
        }

        let playerId = managerOneSignal.getOneSignalAppId()

        guard let fullname = fullNameInput.text,
            let password = passwordInput.text?.md5().sha1(),
            let email = emailInput.text?.lowercased()
            else { return }

        let parameters = [
            "playerID": playerId,
            "fullName": fullname,
            "password": password,
            "email": email
            ] as [String: Any]

        apiManager.performOperation(
            parameters: parameters,
            route: .register,
            method: .POST,
            completionHandler: handleRegister)
    }
}
