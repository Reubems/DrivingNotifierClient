import Foundation
import UIKit

class DrivingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    weak var delegate: NavigationFlow?
    weak var detector: DriveDetector? {
        didSet {
            oldValue?.remove(observer: self)
            detector?.add(observer: self)
        }
    }

    private let apiManager = DrivingNotifierAPIManager()
    private var contactsDrivingData: [User] = []
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
        spinnerView = UIViewController.displaySpinner(onView: view)
        title = "Driving"
        view.backgroundColor = Color.softWhite.value
        guard let email = Session.email else { return }
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = view.frame.width
        let displayHeight: CGFloat = view.frame.height

        tableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        tableView.separatorStyle = .none
        tableView.autoresizingMask = .flexibleWidth
        tableView.registerClass(ContactDrivingCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 60
        tableView.isHidden = true
        view.addSubview(tableView)

        emptyLabel.text = "There is no contact driving now :("
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = UIColor.darkText
        emptyLabel.numberOfLines = 0

        view.addSubview(emptyLabel)

        emptyLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.center.equalToSuperview()
        }

//        apiManager.performOperation(route: .contactsDriving(email: email), method: .GET, completionHandler: handlerLoadingData)
          apiManager.performOperation(route: .allUsers, method: .GET, completionHandler: handlerLoadingData)

    }

    func handlerLoadingData(data: Data?, response: URLResponse?, error: Error?) {
        UIViewController.removeSpinner(spinner: spinnerView)
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode([User].self, from: data ?? Data())
            contactsDrivingData = decoded
            refreshData()
        } catch { print(error)}
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
        return contactsDrivingData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ContactDrivingCell.self, forIndexPath: indexPath)
        if let name = contactsDrivingData[indexPath.row].fullName?.description {
            cell.name.text = "\(name)"
        }
        if let email = contactsDrivingData[indexPath.row].email?.description {
            cell.email.text = "\(email)"
        }
        return cell
    }
}
