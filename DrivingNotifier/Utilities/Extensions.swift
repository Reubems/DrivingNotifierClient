import Foundation
import UIKit
import CryptoSwift

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: alpha
        )
    }

    convenience init(rgb: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            alpha: alpha
        )
    }
}

extension UITableViewCell {
    class func identifier() -> String {
        return NSStringFromClass(self)
    }
}

extension UITableViewHeaderFooterView {
    class func identifier() -> String {
        return NSStringFromClass(self)
    }
}

extension UITableView {
    func registerClass<T: UITableViewCell>(_ cellClass: T.Type) {
        register(cellClass, forCellReuseIdentifier: cellClass.identifier())
    }

    func registerClass<T: UITableViewHeaderFooterView>(_ cellClass: T.Type) {
        register(cellClass, forHeaderFooterViewReuseIdentifier: cellClass.identifier())
    }

    func dequeueReusableCell<T: UITableViewCell>(_ cellClass: T.Type, forIndexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: cellClass.identifier(), for: forIndexPath) as! T //swiftlint:disable:this force_cast
    }

    func dequeueReusableHeaderFooter<T: UITableViewHeaderFooterView>(_ cellClass: T.Type) -> T {
        return dequeueReusableHeaderFooterView(withIdentifier: cellClass.identifier()) as! T //swiftlint:disable:this force_cast
    }
}

extension String {

    enum RegularExpressions: String {
        case email = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        case password = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
        //Minimum 8 characters at least 1 Alphabet and 1 Number:
    }

    func isValid(regex: RegularExpressions) -> Bool {
        return isValid(regex: regex.rawValue)
    }

    func isValid(regex: String) -> Bool {
        let matches = range(of: regex, options: .regularExpression)
        return matches != nil
    }

}

extension UIButton {
    func preventRepeatedPresses(inNext seconds: Double = 1) {
        self.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            self.isUserInteractionEnabled = true
        }
    }
}

extension UIViewController {
    class func displaySpinner(onView: UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = Color.softWhite.value
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .gray) //swiftlint:disable:this identifier_name
        ai.startAnimating()
        ai.center = spinnerView.center

        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        return spinnerView
    }

    class func removeSpinner(spinner: UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}

extension UIViewController: DriveDetectorDelegate {

    func handlerPushNotification(data: Data?, response: URLResponse?, error: Error?) {
        //TODO
    }

    func handlerUpdate(data: Data?, response: URLResponse?, error: Error?) {
        let httpResponse = response as? HTTPURLResponse
        guard let email = Session.email else { return }

        if httpResponse?.statusCode == 200 {
            let apiManager = DrivingNotifierAPIManager()

            let parameters = [
                "email": email ] as [String: Any]

            apiManager.performOperation(
                parameters: parameters,
                route: .pushNotification,
                method: .POST,
                completionHandler: handlerPushNotification)
        }
    }

    func didUpdate(_ detection: DriveDetection) {

        let state: DriveDetectorDrivingState = detection.state
        guard let driving = Session.driving else { return }
        guard let email = Session.email else { return }

        if state == DriveDetectorDrivingState.driving && email.count > 0 && driving == false {

            let parameters = [
                "email": email,
                "driving": true] as [String: Any]
            let apiManager = DrivingNotifierAPIManager()
            Session.driving = true

            apiManager.performOperation(
                parameters: parameters,
                route: .driving,
                method: .PUT,
                completionHandler: handlerUpdate)
        }

    }
}
