import Foundation
import UIKit

class ContactListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    weak var delegate: NavigationFlow?
    weak var detector: DriveDetector? {
        didSet {
            oldValue?.remove(observer: self)
            detector?.add(observer: self)
        }
    }

    let apiManager = DrivingNotifierAPIManager()

    private var contactsData: [User] = []
    private var tableView = UITableView()
    private var spinnerView = UIView()
    private let emptyLabel = UILabel()

    required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        spinnerView = UIViewController.displaySpinner(onView: self.view)
        title = "Contacts List"
        view.backgroundColor = Color.softWhite.value
        guard let email = Session.email else { return }
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = view.frame.width
        let displayHeight: CGFloat = view.frame.height

        tableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        tableView.separatorStyle = .none
        tableView.autoresizingMask = .flexibleWidth
        tableView.registerClass(ContactCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = true
        view.addSubview(tableView)

        emptyLabel.text = "You haven't added a contact yet :("
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = UIColor.darkText
        emptyLabel.numberOfLines = 0

        view.addSubview(emptyLabel)

        emptyLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.center.equalToSuperview()
        }

//        apiManager.performOperation(route: .contacts(email: email), method: .GET, completionHandler: handlerLoadingData)
               apiManager.performOperation(route: .allUsers, method: .GET, completionHandler: handlerLoadingData)

    }

    func handlerLoadingData(data: Data?, response: URLResponse?, error: Error?) {
        UIViewController.removeSpinner(spinner: spinnerView)
        let httpResponse = response as? HTTPURLResponse
        if httpResponse?.statusCode == 200 {
            let decoder = JSONDecoder()
            do {
                let decoded = try decoder.decode([User].self, from: data ?? Data())
                if decoded.count > 0 {
                    contactsData = decoded
                    refreshData()
                } else {
                    DispatchQueue.main.async { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.emptyLabel.isHidden = false
                    }
                }
            } catch { print(error)}
        }
    }

    func handlerDeleteContact(data: Data?, response: URLResponse?, error: Error?) {
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(User.self, from: data ?? Data())
            contactsData = contactsData.filter { $0.email != decoded.email }
            refreshData()
        } catch { print(error) }
    }

    func refreshData() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.tableView.isHidden = false
            strongSelf.emptyLabel.isHidden = true
            strongSelf.tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ContactCell.self, forIndexPath: indexPath)
        if let name = contactsData[indexPath.row].fullName?.description {
            cell.name.text = "\(name)"
        }
        if let email = contactsData[indexPath.row].email?.description {
            cell.email.text = "\(email)"
        }
        cell.handler = self  //Important for the protocol
        return cell
    }
}

extension ContactListViewController: ContactCellDelegate {

    func deleteContact(email: String) {
        guard let requestorEmail = Session.email else { return }
        apiManager.performOperation(
            route: .deleteContactBetween(requestorEmail: requestorEmail, replierEmail: email),
            method: .DELETE,
            completionHandler: handlerDeleteContact)
    }

}
