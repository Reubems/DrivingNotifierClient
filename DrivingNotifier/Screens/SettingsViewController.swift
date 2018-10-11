import Foundation
import UIKit
import SnapKit
import OneSignal

class SettingsViewController: UIViewController {

    weak var delegate: NavigationFlow?
    weak var detector: DriveDetector? {
        didSet {
            oldValue?.remove(observer: self)
            detector?.add(observer: self)
        }
    }
    private var section: SectionView?
    private let apiManager = DrivingNotifierAPIManager()
    private var email: String?
    private let deleteAccountButton = UIButton()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() { // swiftlint:disable:this function_body_length
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        let muteSection = SectionView(type: SectionType.mute, completionHandler: self)
            muteSection.setUp(
                title: "Mute",
                description: "Choose if you want to receive notifications of your contacts.",
                onImageName: "volume_black",
                offImageName: "mute_white")
            muteSection.sectionSwitch.isOn = Session.mute ?? false
            muteSection.updateSectionView()

        let trackingSection = SectionView(type: SectionType.tracking, completionHandler: self)
            trackingSection.setUp(
                title: "Tracking",
                description: "Choose if you want your contacts know when you are driving.",
                onImageName: "check_black",
                offImageName: "disable_white")
            trackingSection.sectionSwitch.isOn = Session.trackingEnabled ?? false
            trackingSection.updateSectionView()

        deleteAccountButton.setTitleColor(Color.softWhite.value, for: .normal)
        deleteAccountButton.backgroundColor = Color.cosmos.value
        deleteAccountButton.isEnabled = true
        deleteAccountButton.layer.borderColor = UIColor.darkText.cgColor
        deleteAccountButton.layer.borderWidth = 2
        deleteAccountButton.layer.cornerRadius = 6
        deleteAccountButton.setTitle("Delete account", for: .normal)
        deleteAccountButton.addTarget(self, action: #selector(deleteAccount), for: .touchDown)

        let stackView = UIStackView()
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            stackView.addArrangedSubview(muteSection)
            stackView.addArrangedSubview(trackingSection)
            stackView.addArrangedSubview(deleteAccountButton)
            stackView.alignment = .fill
            stackView.distribution = .equalSpacing
            stackView.axis = .vertical
            stackView.spacing = 20

        let scrollView = UIScrollView(frame: .zero)
            scrollView.alwaysBounceVertical = true

        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
//            make.top.left.right.equalToSuperview()
        }

        scrollView.snp.makeConstraints { make in
            make.edges.width.height.equalToSuperview()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func handleDelete(data: Data?, response: URLResponse?, error: Error?) {
        let httpResponse = response as? HTTPURLResponse

        if httpResponse?.statusCode == 200 {
            Session.driving = false
            Session.email = nil
            Session.trackingEnabled = false
            Session.mute = false
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.navigate(from: strongSelf)
            }
        }
    }

    @objc func deleteAccount() {
        guard let email = Session.email else { return }
        apiManager.performOperation(route: .deleteUserWith(email: email), method: .DELETE, completionHandler: handleDelete)
    }
}

protocol SectionViewDelegate: class {
    func handleData(data: Data?, response: URLResponse?, error: Error?)
}

class SectionView: UIStackView {

    private let title = UILabel()
    private let descriptionText = UILabel()
    private var onImageName = ""
    private var offImageName = ""
    private var imageView = UIImageView()
    private let backgroundView = UIView()
    private let apiManager = DrivingNotifierAPIManager()
    private var section: SectionType?
    var sectionSwitch = UISwitch()
    weak var handler: SectionViewDelegate?

    init(type: SectionType, completionHandler: SectionViewDelegate) {
        super.init(frame: .zero)
        section = type
        handler = completionHandler
        backgroundView.layer.cornerRadius=20
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUp(title: String, description: String, onImageName: String, offImageName: String) {

        addSubview(backgroundView)

        self.onImageName = onImageName
        self.offImageName = offImageName

        sectionSwitch.backgroundColor = Color.softWhite.value
        sectionSwitch.thumbTintColor = Color.sky.value
        sectionSwitch.tintColor = Color.softDarkness.value
        sectionSwitch.contentMode = .center
        sectionSwitch.onTintColor = Color.shadow.value
        sectionSwitch.addTarget(self, action: #selector(switchToggled), for: .valueChanged)

        let image = UIImage(named: self.onImageName)
        imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit

        self.title.text = title
        descriptionText.text = description

        descriptionText.numberOfLines = 0
        descriptionText.textAlignment  = .center
        descriptionText.font = descriptionText.font.withSize(14)

        self.title.numberOfLines = 0
        self.title.textAlignment  = .center

        isLayoutMarginsRelativeArrangement = true
        layoutMargins = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        addArrangedSubview(self.title)
        addArrangedSubview(descriptionText)
        distribution = .equalCentering
        axis = .vertical
        spacing = 20

        let stackViewSwitch = UIStackView()
            stackViewSwitch.isLayoutMarginsRelativeArrangement = true
            stackViewSwitch.layoutMargins = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
            stackViewSwitch.addArrangedSubview(imageView)
            stackViewSwitch.addArrangedSubview(sectionSwitch)
            stackViewSwitch.distribution = .fillEqually
            stackViewSwitch.axis = .horizontal
            stackViewSwitch.spacing = 20

        addArrangedSubview(stackViewSwitch)

        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        sendSubview(toBack: backgroundView)
    }

    func performSectionOperation() {
        guard let handler = self.handler else { return }
        guard let email = Session.email else { return }
        var sectionString: String?
        if section == .mute {
            sectionString = "mute"
        } else if section == .tracking {
            sectionString = "trackingEnabled"
        }
        guard sectionString != nil, let param = sectionString else { return }
        let paramsOn = ["email": email, param: true] as [String: Any]
        let paramsOff = ["email": email, param: false] as [String: Any]

        apiManager.performOperation(
            parameters: self.sectionSwitch.isOn ? paramsOn : paramsOff,
            route: section == .mute ? APIRoutes.muteState : APIRoutes.trackingState,
            method: DrivingNotifierAPIManager.HttpMethod.PUT,
            completionHandler: handler.handleData(data:response:error:))
    }

    func updateSectionView() {
        if sectionSwitch.isOn {
            descriptionText.textColor = Color.softWhite.value
            title.textColor = Color.softWhite.value
            UIView.animate(withDuration: 1, animations: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.backgroundView.backgroundColor = Color.softDarkness.value
                strongSelf.sectionSwitch.backgroundColor = Color.softDarkness.value
                let image = UIImage(named: strongSelf.offImageName)
                strongSelf.imageView.image = image
            })
        } else {
            descriptionText.textColor = Color.cosmos.value
            title.textColor = Color.cosmos.value
            UIView.animate(withDuration: 1, animations: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.backgroundView.backgroundColor = Color.softWhite.value
                strongSelf.sectionSwitch.backgroundColor = Color.softWhite.value
                let image = UIImage(named: strongSelf.onImageName)
                strongSelf.imageView.image = image
            })
        }
    }

    @objc func switchToggled(sender: UISwitch) {
        updateSectionView()
        performSectionOperation()
    }
}

enum SectionType {
    case mute, tracking
}

extension SettingsViewController: SectionViewDelegate {

    func handleData(data: Data?, response: URLResponse?, error: Error?) {
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode([User].self, from: data ?? Data())
            print(decoded.description)
        } catch { print(error) }
    }

}
