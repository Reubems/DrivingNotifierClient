import Foundation

enum APIRoutes {
    case register
    case login
    case allUsers
    case deleteUserWith(email: String)
    case findUserWith(email: String)
    case resetPasswordForUserWith(email: String)
    case deleteContactBetween(requestorEmail: String, replierEmail: String)
    case contactsDriving(email: String)
    case contacts(email: String)
    case updatePassword
    case pushNotification
    case trackingState
    case muteState
    case driving
    case createRequest, allRequests, updateRequests
    case deleteRequestBetween(requestorEmail: String, replierEmail: String)
    case findRequestBetween(requestorEmail: String, replierEmail: String)
    case pendingRequestsFromUserWith(email: String)
}

extension APIRoutes {
    var urlString: String {
        switch self {
        case .register:
            return "/api/Users/Register"
        case .login:
            return "/api/Users/Login"
        case .allUsers:
            return "/api/Users"
        case .driving:
            return "/api/Users/Driving"
        case let .contactsDriving(email):
            return "/api/Users/Driving/\(email)"
        case let .contacts(email):
            return "/api/Users/Contacts/\(email)"
        case let .resetPasswordForUserWith(email):
            return "/api/Users/ResetPassword/\(email)"
        case .updatePassword:
            return "/api/Users/UpdatePassword"
        case .pushNotification:
            return "/api/Users/PushNotification"
        case .trackingState:
            return "/api/Users/TrackingEnabled"
        case .muteState:
            return "/api/Users/Mute"
        case .createRequest, .allRequests, .updateRequests:
            return "/api/Requests"
        case let .deleteUserWith(email):
            return "/api/Users/\(email)"
        case let .findUserWith(email):
            return "/api/Users/\(email)"
        case let .pendingRequestsFromUserWith(email):
            return "/api/Requests/PendingRequests/\(email)"
        case let .deleteContactBetween(requestorEmail, replierEmail):
            return "/api/Users/Contacts/\(requestorEmail)/\(replierEmail)"
        case let .deleteRequestBetween(requestorEmail, replierEmail):
            return "/api/Requests/\(requestorEmail)/\(replierEmail)"
        case let .findRequestBetween(requestorEmail, replierEmail):
            return "/api/Requests/\(requestorEmail)/\(replierEmail)"
        }
    }
}
