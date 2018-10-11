import UIKit
import OneSignal
import SnapKit

protocol AppProtocol {
    func didLaunch(detector: DriveDetector)
}

class App {
    private let window = UIWindow(frame: UIScreen.main.bounds)
    private weak var detector: DriveDetector?

}

protocol NavigationFlow: class {
    func navigate(from viewControllerSource: LoginViewController)
    func navigate(from viewControllerSource: SettingsViewController)
    func navigate(from viewControllerSource: ResetPasswordViewController)
    func navigate(from viewControllerSource: RegisterViewController)
    func resetPassword(from viewControllerSource: LoginViewController)
    func register(from viewControllerSource: LoginViewController)
}

extension App: AppProtocol {

    func didLaunch(detector: DriveDetector) {
        self.detector = detector
        let lvc = LoginViewController()
//        let lvc = ResetPasswordViewController()
        lvc.delegate = self
        window.rootViewController = UINavigationController(rootViewController: lvc)
        window.makeKeyAndVisible()
    }
}

extension App: NavigationFlow {
    func resetPassword(from viewControllerSource: LoginViewController) {
        let rpvc = ResetPasswordViewController()
        rpvc.detector = detector
        rpvc.delegate = self

        viewControllerSource.navigationController?.pushViewController(rpvc, animated: true)
    }

    func register(from viewControllerSource: LoginViewController) {
        let rvc = RegisterViewController()
        rvc.detector = detector
        rvc.delegate = self
        viewControllerSource.navigationController?.pushViewController(rvc, animated: true)
    }

    func navigate(from viewControllerSource: SettingsViewController) {
        viewControllerSource.navigationController?.popViewController(animated: true)
    }

    func navigate(from viewControllerSource: RegisterViewController) {
        viewControllerSource.navigationController?.popViewController(animated: true)
    }

    func navigate(from viewControllerSource: ResetPasswordViewController) {
        viewControllerSource.navigationController?.popViewController(animated: true)
    }

    func navigate(from viewControllerSource: LoginViewController) {

        let tabBarController = UITabBarController()
            tabBarController.tabBar.barTintColor = Color.softWhite.value
            //tabBarController.tabBar.tintColor = Color.sky.value
            tabBarController.tabBar.unselectedItemTintColor = Color.cosmos.value

        let settingsTabBarItem: UITabBarItem = UITabBarItem(
            title: "Status",
            image: UIImage(named: "businessman")?.withRenderingMode(UIImageRenderingMode.automatic),
            selectedImage: UIImage(named: "businessman"))

        let drivingTabBarItem: UITabBarItem = UITabBarItem(
            title: "Driving",
            image: UIImage(named: "car")?.withRenderingMode(UIImageRenderingMode.automatic),
            selectedImage: UIImage(named: "car"))

        let contactsTabBarItem: UITabBarItem = UITabBarItem(
            title: "Contacts",
            image: UIImage(named: "people")?.withRenderingMode(UIImageRenderingMode.automatic),
            selectedImage: UIImage(named: "people"))

        let requestsTabBarItem: UITabBarItem = UITabBarItem(
            title: "Requests",
            image: UIImage(named: "add_user_male")?.withRenderingMode(UIImageRenderingMode.automatic),
            selectedImage: UIImage(named: "add_user_male"))

        let svc = SettingsViewController()
        svc.tabBarItem = settingsTabBarItem
        svc.delegate = self
        svc.detector = detector

        let drivingVC = DrivingViewController()
        drivingVC.tabBarItem = drivingTabBarItem
        drivingVC.delegate = self
        drivingVC.detector = detector

        let contactVC = ContactListViewController()
        contactVC.tabBarItem = contactsTabBarItem
        contactVC.delegate = self
        contactVC.detector = detector

        let requestVC = RequestViewController()
        requestVC.tabBarItem = requestsTabBarItem
        requestVC.delegate = self
        requestVC.detector = detector

        tabBarController.viewControllers = [svc, drivingVC, contactVC, requestVC]
        viewControllerSource.navigationController?.pushViewController(tabBarController, animated: true)
    }

}
