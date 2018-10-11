import Foundation
import OneSignal

class OneSignalApiManager {

    func getOneSignalAppId() -> String {
        //Get current user's id
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        let userId = status.subscriptionStatus.userId
        return userId ?? ""
    }

}
