import Foundation
import UIKit
import SnapKit

class LoginViewController: UIViewController {

    private let apiManager = DrivingNotifierAPIManager()
    private let managerOneSignal = OneSignalApiManager()

    weak var delegate: NavigationFlow?
    weak var detector: DriveDetector? {
        didSet {
            oldValue?.remove(observer: self)
            detector?.add(observer: self)
        }
    }
    private var formLabel = UILabel()
    private var emailInput = UITextField()
    private var emailLabel = UILabel()
    private var passwordInput = UITextField()
    private var passwordLabel = UILabel()
    private var registerLabel = UILabel()
    private var resetPasswordLabel = UILabel()

    private var loginButton = UIButton()
    private var registerButton = UIButton()
    private var resetPasswordButton = UIButton()

    override func viewDidLoad() { // swiftlint:disable:this function_body_length
        super.viewDidLoad()
        title = "Main"
        view.backgroundColor = Color.softWhite.value
        hideKeyboardWhenTappedAround()

        [emailInput, passwordInput].forEach { input in
            input.backgroundColor = UIColor.white
            input.borderStyle = .roundedRect
        }

        [formLabel, emailLabel, passwordLabel].forEach { label in
            label.textColor = UIColor.red
            label.numberOfLines = 0
            label.isHidden = true
        }

        [registerLabel, resetPasswordLabel].forEach { label in
            label.textColor = Color.cosmos.value
            label.textAlignment = .center
            label.numberOfLines = 0
        }

        [registerButton, resetPasswordButton].forEach { button in
            button.setTitleColor(Color.softWhite.value, for: .normal)
            button.backgroundColor = Color.cosmos.value
            button.isEnabled = true
            button.layer.borderColor = UIColor.darkText.cgColor
            button.layer.borderWidth = 2
            button.layer.cornerRadius = 6
        }

        emailInput.placeholder = "Email"
        emailInput.addTarget(self, action: #selector(validateEmail), for: .editingDidEnd)
        passwordInput.placeholder = "Insert password"
        passwordInput.isSecureTextEntry = true
        passwordInput.addTarget(self, action: #selector(validatePassword), for: .editingDidEnd)

        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitleColor(Color.cosmos.value, for: .normal)
        loginButton.backgroundColor = UIColor.white
        loginButton.isEnabled = true
        loginButton.layer.borderColor = UIColor.darkText.cgColor
        loginButton.layer.borderWidth = 2
        loginButton.layer.cornerRadius = 6
        loginButton.addTarget(self, action: #selector(validateForm), for: .touchDown)

        registerLabel.text = "Haven't already an account? Press register to create a new one: "

        registerButton.setTitle("Register", for: .normal)
        registerButton.addTarget(self, action: #selector(register), for: .touchDown)

        resetPasswordLabel.text = "If you forgot your password you can reset it here: "

        resetPasswordButton.setTitle("Reset password", for: .normal)
        resetPasswordButton.addTarget(self, action: #selector(resetPassword), for: .touchDown)

        let stackView = UIStackView()
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        stackView.addArrangedSubview(formLabel)
        stackView.addArrangedSubview(emailInput)
        stackView.addArrangedSubview(emailLabel)
        stackView.addArrangedSubview(passwordInput)
        stackView.addArrangedSubview(passwordLabel)
        stackView.addArrangedSubview(loginButton)
        stackView.addArrangedSubview(registerLabel)
        stackView.addArrangedSubview(registerButton)
        stackView.addArrangedSubview(resetPasswordLabel)
        stackView.addArrangedSubview(resetPasswordButton)
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

    func handler(data: Data?, response: URLResponse?, error: Error?) {
        let httpResponse = response as? HTTPURLResponse
        if httpResponse?.statusCode == 200 {

            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                guard let email = strongSelf.emailInput.text?.lowercased() else { return }
                let decoder = JSONDecoder()
                do {
                    let decoded = try decoder.decode(User.self, from: data ?? Data())
                    Session.email = email
                    Session.driving = false
                    Session.mute = decoded.mute
                    Session.trackingEnabled = decoded.trackingEnabled

                    strongSelf.delegate?.navigate(from: strongSelf)
                } catch { print(error) }
            }
        }
    }

    @objc func validateEmail() {
        guard let email = emailInput.text else { return }
        if email.isValid(regex: .email) {
            emailLabel.isHidden = true
            loginButton.isEnabled = true
        } else {
            loginButton.isEnabled = false
            emailLabel.isHidden = false
            emailLabel.text = "Insert a valid e-mail."
        }
    }

    @objc func validatePassword() {
        guard let password = passwordInput.text else { return }
        if password.isValid(regex: .password) {
            passwordLabel.isHidden = true
            loginButton.isEnabled = true
        } else {
            loginButton.isEnabled = false
            passwordLabel.isHidden = false
            passwordLabel.text = "Password must have minimum 8 characters at least 1 Alphabet and 1 Number."
        }
    }

    @objc func validateForm(sender: UIButton) {
        sender.preventRepeatedPresses()
        var inputs = [emailInput, passwordInput]
        inputs = inputs.filter { $0.text?.count == 0}
        if inputs.count > 0 {
            formLabel.isHidden = false
            formLabel.text = "Complete all the fields!"
            return
        } else {
            formLabel.isHidden = true
        }

        let playerId = managerOneSignal.getOneSignalAppId()

        guard let email = emailInput.text?.lowercased(),
            let password = passwordInput.text?.md5().sha1()
            else { return }

        let parameters = [
            "playerID": playerId,
            "email": email,
            "password": password
            ] as [String: Any]

        apiManager.performOperation(
            parameters: parameters,
            route: .login,
            method: .POST,
            completionHandler: handler)
    }

    @objc func register(sender: UIButton) {
        sender.preventRepeatedPresses()
        delegate?.register(from: self)
    }

    @objc func resetPassword(sender: UIButton) {
        sender.preventRepeatedPresses()
        delegate?.resetPassword(from: self)
    }
}
