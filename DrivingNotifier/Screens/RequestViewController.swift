import Foundation
import UIKit

class RequestViewController: UIViewController {

    weak var delegate: NavigationFlow?
    weak var detector: DriveDetector? {
        didSet {
            oldValue?.remove(observer: self)
            detector?.add(observer: self)
        }
    }
    private let apiManager = DrivingNotifierAPIManager()

    private var emailLabel = UILabel()
    private var emailInput = UITextField()
    private var emailLabelError = UILabel()
    private var sendButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()

        title = "Requests"
        view.backgroundColor = Color.softWhite.value

        emailLabel.text = "Introduce the email to make the request: "
        emailLabel.textColor = UIColor.darkGray
        emailLabel.numberOfLines = 0

        emailInput.backgroundColor = UIColor.white
        emailInput.placeholder = "E-mail"
        emailInput.addTarget(self, action: #selector(textFieldDidChange), for: .editingDidEnd)
        emailInput.borderStyle = .roundedRect

        emailLabelError.textColor = UIColor.red
        emailLabelError.numberOfLines = 0
        emailLabelError.isHidden = true

        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(Color.softWhite.value, for: .normal)
        sendButton.backgroundColor = Color.cosmos.value
        sendButton.isEnabled = true
        sendButton.layer.borderColor = UIColor.darkText.cgColor
        sendButton.layer.borderWidth = 2
        sendButton.layer.cornerRadius = 6
        sendButton.addTarget(self, action: #selector(sendRequest), for: .touchDown)

        let stackView = UIStackView()
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        stackView.addArrangedSubview(emailLabel)
        stackView.addArrangedSubview(emailInput)
        stackView.addArrangedSubview(emailLabelError)
        stackView.addArrangedSubview(sendButton)
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 20

        view.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
    }

    func handlerRequest(data: Data?, response: URLResponse?, error: Error?) {
        //TODO Handle responses codes.
    }

    @objc func textFieldDidChange() {
        guard let email = emailInput.text else { return }
        if email.isValid(regex: .email) {
            sendButton.isEnabled = true
            emailLabelError.isHidden = true
        } else {
            sendButton.isEnabled = false
            emailLabelError.isHidden = false
            emailLabelError.text = "Invalid e-mail format"
        }
    }

    @objc func sendRequest(sender: UIButton) {
        sender.preventRepeatedPresses()
        guard let replierEmail = emailInput.text?.lowercased() else { return }
        guard let requestorEmail = Session.email else { return }
        let parameters = [
            "requestorEmail": requestorEmail,
            "replierEmail": replierEmail,
            "state": 0  //Pending
            ] as [String: Any]

        apiManager.performOperation(
            parameters: parameters,
            route: .createRequest,
            method: .POST,
            completionHandler: handlerRequest)

    }
}
