import UIKit
import OneSignal
import HumioCocoaLumberjackLogger

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private let app: AppProtocol = App()
    private let detector = DriveDetector()
    private var logging: HumioLogger?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]

        // Replace 'YOUR_APP_ID' with your OneSignal App ID.
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "29d6b657-f182-41e7-85cd-1807d337fdfc",
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)

        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification

        // Recommend moving the below line to prompt for push after informing the user about
        //   how your app will use them.
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })

        // Sync hashed email if you have a login system or collect it.
        //   Will be used to reach the user at the most optimal time of day.
        // OneSignal.syncHashedEmail(userEmail)
        /*let logger = HumioLoggerFactory.createLogger(
            serviceUrl:URL(string: "https://go.humio.com/api/v1/dataspaces/gpsgaps/ingest"),
            accessToken:"HPVQT83g0bZCS4vR9SqYmkgm5cVh58aNxCMdmMy0iwTb",
            dataSpace:"gpsgaps",
            loggerId:id
        )

        DDLog.add(logger)
        DDLog.add(DDTTYLogger.sharedInstance())

        logging = logger

        DDLogDebug("did launch app with device id: \(id)") */

        app.didLaunch(detector: detector)

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
       // DDLogDebug("app did became active")
        detector.activate()
        detector.performUpdate()
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

}
